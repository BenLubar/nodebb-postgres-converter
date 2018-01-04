const { Pool } = require('pg');
const copyDatabase = require('./copy.js');
const transaction = require('./transaction.js');

async function query(label, conn, query) {
	var shouldRelease = false;
	if (!conn.release) {
		shouldRelease = true;
		conn = await conn.connect();
	}

	console.time(label);

	try {
		await conn.query(query);
	} catch (ex) {
		console.error('Query failed: ' + label);
		throw ex;
	} finally {
		console.timeEnd(label);

		if (shouldRelease) {
			conn.release();
		}
	}
}

async function main(reader, input, output, concurrency, memory) {
	const pool = new Pool({
		connectionString: output,
		max: concurrency,
		application_name: 'nodebb-postgres-converter'
	});

	pool.on('connect', function(client) {
		client.on('notice', function(notice) {
			console.log('[DB] ' + notice.message + (notice.detail ? '\n' + notice.detail : ''));
		});
	});

	console.time('Copy');

	await query('Create table objects', pool, 'CREATE TABLE "objects" ( "data" JSONB NOT NULL CHECK (("data" ? \'_key\')) )');

	await copyDatabase(pool, reader, input);

	console.timeEnd('Copy');

	console.time('Index');

	await Promise.all([
		query('Create index on key__score', pool, 'CREATE INDEX IF NOT EXISTS "idx__objects__key__score" ON "objects"(("data"->>\'_key\') ASC, (("data"->>\'score\')::numeric) DESC)'),
		query('Create unique index on key', pool, 'CREATE UNIQUE INDEX IF NOT EXISTS "uniq__objects__key" ON "objects"(("data"->>\'_key\')) WHERE NOT ("data" ? \'score\')'),
		query('Create unique index on key__value', pool, 'CREATE UNIQUE INDEX IF NOT EXISTS "uniq__objects__key__value" ON "objects"(("data"->>\'_key\') ASC, ("data"->>\'value\') DESC)'),
		query('Create index on expireAt', pool, 'CREATE INDEX IF NOT EXISTS "idx__objects__expireAt" ON "objects"((("data"->>\'expireAt\')::numeric) ASC) WHERE "data" ? \'expireAt\'')
	]);

	console.timeEnd('Index');

	console.time('Cluster');

	await query('Cluster objects', pool, {text: 'SELECT set_config(\'maintenance_work_mem\', $1::TEXT, true); CLUSTER VERBOSE "objects" USING "idx__objects__key__score"', values: [memory]});

	console.timeEnd('Cluster');

	console.time('Analyze');

	await query('Analyze objects', pool, 'ANALYZE VERBOSE "objects"');

	console.timeEnd('Analyze');

	console.time('Convert');

	await transaction('Objects', pool, async function(db) {
		await query('Create type legacy_object_type', db, 'CREATE TYPE LEGACY_OBJECT_TYPE AS ENUM (\'hash\', \'zset\', \'set\', \'list\', \'string\')');

		await query('Create table legacy_object', db, 'CREATE TABLE "legacy_object" ( "_key" TEXT NOT NULL PRIMARY KEY, "type" LEGACY_OBJECT_TYPE NOT NULL, "expireAt" TIMESTAMPTZ DEFAULT NULL, UNIQUE ( "_key", "type" ) )');

		await query('Insert into legacy_object (zset)', db, 'INSERT INTO "legacy_object" ("_key", "type", "expireAt") SELECT "data"->>\'_key\', \'zset\'::LEGACY_OBJECT_TYPE, MIN(CASE WHEN ("data" ? \'expireAt\') THEN to_timestamp(("data"->>\'expireAt\')::double precision / 1000) ELSE NULL END) FROM "objects" WHERE "data" ? \'score\' GROUP BY "data"->>\'_key\'');

		await query('Insert into legacy_object (string, set, list, hash)', db, 'INSERT INTO "legacy_object" ("_key", "type", "expireAt") SELECT "data"->>\'_key\', CASE WHEN (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 2 THEN CASE WHEN ("data" ? \'value\') OR ("data" ? \'data\') THEN \'string\' WHEN "data" ? \'array\' THEN \'list\' WHEN "data" ? \'members\' THEN \'set\' ELSE \'hash\' END ELSE \'hash\' END::LEGACY_OBJECT_TYPE, CASE WHEN ("data" ? \'expireAt\') THEN to_timestamp(("data"->>\'expireAt\')::double precision / 1000) ELSE NULL END FROM "objects" WHERE NOT ("data" ? \'score\')');

		await query('Create index on expireAt', db, 'CREATE INDEX "idx__legacy_object__expireAt" ON "legacy_object"("expireAt" ASC)');
	});

	await query('Create table legacy_hash', pool, 'CREATE TABLE "legacy_hash" ( "_key" TEXT NOT NULL PRIMARY KEY, "data" JSONB NOT NULL, "type" LEGACY_OBJECT_TYPE NOT NULL DEFAULT \'hash\'::LEGACY_OBJECT_TYPE CHECK ( "type" = \'hash\' ), CONSTRAINT "fk__legacy_hash__key" FOREIGN KEY ("_key", "type") REFERENCES "legacy_object"("_key", "type") ON UPDATE CASCADE ON DELETE CASCADE )');

	await query('Create table legacy_zset', pool, 'CREATE TABLE "legacy_zset" ( "_key" TEXT NOT NULL, "value" TEXT NOT NULL, "score" NUMERIC NOT NULL, "type" LEGACY_OBJECT_TYPE NOT NULL DEFAULT \'zset\'::LEGACY_OBJECT_TYPE CHECK ( "type" = \'zset\' ), PRIMARY KEY ("_key", "value"), CONSTRAINT "fk__legacy_zset__key" FOREIGN KEY ("_key", "type") REFERENCES "legacy_object"("_key", "type") ON UPDATE CASCADE ON DELETE CASCADE )');

	await query('Create table legacy_set', pool, 'CREATE TABLE "legacy_set" ( "_key" TEXT NOT NULL, "member" TEXT NOT NULL, "type" LEGACY_OBJECT_TYPE NOT NULL DEFAULT \'set\'::LEGACY_OBJECT_TYPE CHECK ( "type" = \'set\' ), PRIMARY KEY ("_key", "member"), CONSTRAINT "fk__legacy_set__key" FOREIGN KEY ("_key", "type") REFERENCES "legacy_object"("_key", "type") ON UPDATE CASCADE ON DELETE CASCADE )');

	await query('Create table legacy_list', pool, 'CREATE TABLE "legacy_list" ( "_key" TEXT NOT NULL PRIMARY KEY, "array" TEXT[] NOT NULL, "type" LEGACY_OBJECT_TYPE NOT NULL DEFAULT \'list\'::LEGACY_OBJECT_TYPE CHECK ( "type" = \'list\' ), CONSTRAINT "fk__legacy_list__key" FOREIGN KEY ("_key", "type") REFERENCES "legacy_object"("_key", "type") ON UPDATE CASCADE ON DELETE CASCADE )');

	await query('Create table legacy_string', pool, 'CREATE TABLE "legacy_string" ( "_key" TEXT NOT NULL PRIMARY KEY, "data" TEXT NOT NULL, "type" LEGACY_OBJECT_TYPE NOT NULL DEFAULT \'string\'::LEGACY_OBJECT_TYPE CHECK ( "type" = \'string\' ), CONSTRAINT "fk__legacy_string__key" FOREIGN KEY ("_key", "type") REFERENCES "legacy_object"("_key", "type") ON UPDATE CASCADE ON DELETE CASCADE )');

	await Promise.all([
		query('Insert into legacy_hash', pool, 'INSERT INTO "legacy_hash" ("_key", "data") SELECT "data"->>\'_key\', "data" - \'_key\' - \'expireAt\' FROM "objects" WHERE CASE WHEN (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 2 THEN NOT (("data" ? \'value\') OR ("data" ? \'data\') OR ("data" ? \'members\') OR ("data" ? \'array\')) WHEN (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 3 THEN NOT (("data" ? \'value\') AND ("data" ? \'score\')) ELSE TRUE END'),
		query('Insert into legacy_zset', pool, 'INSERT INTO "legacy_zset" ("_key", "value", "score") SELECT "data"->>\'_key\', "data"->>\'value\', ("data"->>\'score\')::numeric FROM "objects" WHERE (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 3 AND ("data" ? \'value\') AND ("data" ? \'score\')'),
		query('Insert into legacy_set', pool, 'INSERT INTO "legacy_set" ("_key", "member") SELECT "data"->>\'_key\', jsonb_array_elements_text("data"->\'members\') FROM "objects" WHERE (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 2 AND ("data" ? \'members\')'),
		query('Insert into legacy_list', pool, 'INSERT INTO "legacy_list" ("_key", "array") SELECT "data"->>\'_key\', ARRAY(SELECT t FROM jsonb_array_elements_text("data"->\'list\') WITH ORDINALITY l(t, i) ORDER BY i ASC) FROM "objects" WHERE (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 2 AND ("data" ? \'array\')'),
		query('Insert into legacy_string', pool, 'INSERT INTO "legacy_string" ("_key", "data") SELECT "data"->>\'_key\', CASE WHEN "data" ? \'value\' THEN "data"->>\'value\' ELSE "data"->>\'data\' END FROM "objects" WHERE (SELECT COUNT(*) FROM jsonb_object_keys("data" - \'expireAt\')) = 2 AND (("data" ? \'value\') OR ("data" ? \'data\'))')
	]);

	await query('Create index on key__score', pool, 'CREATE INDEX "idx__legacy_zset__key__score" ON "legacy_zset"("_key" ASC, "score" DESC)');

	console.timeEnd('Convert');

	console.time('Cleanup');

	await Promise.all([
		query('Drop table objects', pool, 'DROP TABLE "objects" CASCADE'),
		query('Create view legacy_object_live', pool, 'CREATE VIEW "legacy_object_live" AS SELECT "_key", "type" FROM "legacy_object" WHERE "expireAt" IS NULL OR "expireAt" > CURRENT_TIMESTAMP'),
		query('Create table session', pool, 'CREATE TABLE IF NOT EXISTS "session" ( "sid" VARCHAR NOT NULL COLLATE "default", "sess" JSON NOT NULL, "expire" TIMESTAMP(6) NOT NULL, CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE ) WITH (OIDS=FALSE)')
	]);

	console.timeEnd('Cleanup');

	await Promise.all([
		query('Cluster legacy_object', pool, 'ALTER TABLE "legacy_object" CLUSTER ON "legacy_object_pkey"'),
		query('Cluster legacy_hash', pool, 'ALTER TABLE "legacy_hash" CLUSTER ON "legacy_hash_pkey"'),
		query('Cluster legacy_zset', pool, 'ALTER TABLE "legacy_zset" CLUSTER ON "legacy_zset_pkey"'),
		query('Cluster legacy_set', pool, 'ALTER TABLE "legacy_set" CLUSTER ON "legacy_set_pkey"'),
		query('Cluster legacy_list', pool, 'ALTER TABLE "legacy_list" CLUSTER ON "legacy_list_pkey"'),
		query('Cluster legacy_string', pool, 'ALTER TABLE "legacy_string" CLUSTER ON "legacy_string_pkey"')
	]);

	await query('Cluster', pool, {text: 'SELECT set_config(\'maintenance_work_mem\', $1::TEXT, true); CLUSTER VERBOSE', values: [memory]}),

	console.time('Analyze');

	await Promise.all([
		query('Analyze legacy_object', pool, 'ANALYZE VERBOSE "legacy_object"'),
		query('Analyze legacy_hash', pool, 'ANALYZE VERBOSE "legacy_hash"'),
		query('Analyze legacy_zset', pool, 'ANALYZE VERBOSE "legacy_zset"'),
		query('Analyze legacy_set', pool, 'ANALYZE VERBOSE "legacy_set"'),
		query('Analyze legacy_list', pool, 'ANALYZE VERBOSE "legacy_list"'),
		query('Analyze legacy_string', pool, 'ANALYZE VERBOSE "legacy_string"')
	]);

	console.timeEnd('Analyze');

	await pool.end();
}

module.exports = main;
