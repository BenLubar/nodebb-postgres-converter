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

async function main(reader, input, output, concurrency, memory, sessionReader, sessionInput) {
	const pool = new Pool({
		connectionString: output,
		max: concurrency,
		application_name: 'nodebb-postgres-converter',
		verify: async function (client, callback) {
			try {
				await client.query(`SELECT set_config('maintenance_work_mem', $1::TEXT, false)`, [memory]);
			} catch (err) {
				client.release(err);
				return callback(err);
			}
			callback(null, client, client.release);
		}
	});

	pool.on('connect', function(client) {
		client.on('notice', function(notice) {
			console.log('[DB] ' + notice.message + (notice.detail ? '\n' + notice.detail : ''));
		});
	});

	await Promise.all([
		!sessionInput ? Promise.resolve() : transaction('Sessions', pool, async function(db) {
			await query('Create table session', db, `CREATE TABLE IF NOT EXISTS "session" (
	"sid" VARCHAR NOT NULL
		COLLATE "default",
	"sess" JSON NOT NULL,
	"expire" TIMESTAMP(6) NOT NULL
) WITH (OIDS=FALSE)`);

			await require('./session.js')(db, sessionReader, sessionInput);

			await query('Add primary key to session', db, `ALTER TABLE "session"
	ADD CONSTRAINT "session_pkey"
	PRIMARY KEY ("sid")
	NOT DEFERRABLE
	INITIALLY IMMEDIATE`);

			await query('Analyze session', db, `ANALYZE VERBOSE "session"`);
		}),
		transaction('Copy', pool, async function(db) {
			await query('Create table objects', db, `CREATE TABLE "objects" (
	"data" JSONB NOT NULL
		CHECK (("data" ? '_key'))
)`);

			await copyDatabase(db, reader, input);
		})
	]);

	console.time('Index');

	await Promise.all([
		query('Create index on key__score', pool, `CREATE INDEX IF NOT EXISTS "idx__objects__key__score" ON "objects"(("data"->>'_key') ASC, (("data"->>'score')::numeric) DESC)`),
		query('Create unique index on key', pool, `CREATE UNIQUE INDEX IF NOT EXISTS "uniq__objects__key" ON "objects"(("data"->>'_key')) WHERE NOT ("data" ? 'score')`),
		query('Create unique index on key__value', pool, `CREATE UNIQUE INDEX IF NOT EXISTS "uniq__objects__key__value" ON "objects"(("data"->>'_key') ASC, ("data"->>'value') DESC)`),
		query('Create index on expireAt', pool, `CREATE INDEX IF NOT EXISTS "idx__objects__expireAt" ON "objects"((("data"->>'expireAt')::numeric) ASC) WHERE "data" ? 'expireAt'`)
	]);

	console.timeEnd('Index');

	console.time('Analyze');

	await query('Analyze objects', pool, `ANALYZE VERBOSE "objects"`);

	console.timeEnd('Analyze');

	console.time('Convert');

	await transaction('Objects', pool, async function(db) {
		await query('Create type legacy_object_type', db, `CREATE TYPE LEGACY_OBJECT_TYPE AS ENUM ( 'hash', 'zset', 'set', 'list', 'string' )`);

		await query('Create table legacy_object', db, `CREATE TABLE "legacy_object" (
	"_key" TEXT NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL,
	"expireAt" TIMESTAMPTZ
		DEFAULT NULL
)`);

		await query('Insert into legacy_object (zset)', db, `INSERT INTO "legacy_object" ("_key", "type", "expireAt")
SELECT "data"->>'_key', 'zset'::LEGACY_OBJECT_TYPE, MIN(CASE
	WHEN ("data" ? 'expireAt') THEN to_timestamp(("data"->>'expireAt')::double precision / 1000)
	ELSE NULL
END)
  FROM "objects"
 WHERE ("data" ? 'score')
   AND ("data"->>'value' IS NOT NULL)
   AND ("data"->>'score' IS NOT NULL)
 GROUP BY "data"->>'_key'`);

		await query('Insert into legacy_object (string, set, list, hash)', db, `INSERT INTO "legacy_object" ("_key", "type", "expireAt")
SELECT "data"->>'_key', CASE
	WHEN (SELECT COUNT(*) FROM jsonb_object_keys("data" - 'expireAt')) = 2 THEN CASE
		WHEN ("data" ? 'value') OR ("data" ? 'data') THEN 'string'
		WHEN "data" ? 'array' THEN 'list'
		WHEN "data" ? 'members' THEN 'set'
		ELSE 'hash'
	END
	ELSE 'hash'
END::LEGACY_OBJECT_TYPE, CASE
	WHEN ("data" ? 'expireAt') THEN to_timestamp(("data"->>'expireAt')::double precision / 1000)
	ELSE NULL
END
  FROM "objects"
 WHERE NOT ("data" ? 'score')`);

		await query('Add primary key to legacy_object', db, `ALTER TABLE "legacy_object"
	ADD PRIMARY KEY ( "_key" )`);

		await query('Create unique index on key__type', db, `ALTER TABLE "legacy_object"
	ADD UNIQUE ( "_key", "type" )`);

		await query('Create index on expireAt', db, `CREATE INDEX "idx__legacy_object__expireAt" ON "legacy_object"("expireAt" ASC)`);

		await query('Create temporary index on type', db, `CREATE INDEX "idx__legacy_object__type" ON "legacy_object"("type")`);
	});

	await query('Create table legacy_hash', pool, `CREATE TABLE "legacy_hash" (
	"_key" TEXT NOT NULL,
	"data" JSONB NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL
		DEFAULT 'hash'::LEGACY_OBJECT_TYPE
		CHECK ( "type" = 'hash' )
)`);

	await query('Create table legacy_zset', pool, `CREATE TABLE "legacy_zset" (
	"_key" TEXT NOT NULL,
	"value" TEXT NOT NULL,
	"score" NUMERIC NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL
		DEFAULT 'zset'::LEGACY_OBJECT_TYPE
		CHECK ( "type" = 'zset' )
)`);

	await query('Create table legacy_set', pool, `CREATE TABLE "legacy_set" (
	"_key" TEXT NOT NULL,
	"member" TEXT NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL
		DEFAULT 'set'::LEGACY_OBJECT_TYPE
		CHECK ( "type" = 'set' )
)`);

	await query('Create table legacy_list', pool, `CREATE TABLE "legacy_list" (
	"_key" TEXT NOT NULL,
	"array" TEXT[] NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL
		DEFAULT 'list'::LEGACY_OBJECT_TYPE
		CHECK ( "type" = 'list' )
)`);

	await query('Create table legacy_string', pool, `CREATE TABLE "legacy_string" (
	"_key" TEXT NOT NULL,
	"data" TEXT NOT NULL,
	"type" LEGACY_OBJECT_TYPE NOT NULL
		DEFAULT 'string'::LEGACY_OBJECT_TYPE
		CHECK ( "type" = 'string' )
)`);

	await Promise.all([
		query('Insert into legacy_hash', pool, `INSERT INTO "legacy_hash" ("_key", "data")
SELECT l."_key", o."data" - '_key' - 'expireAt'
  FROM "legacy_object" l
 INNER JOIN "objects" o
         ON l."_key" = o."data"->>'_key'
 WHERE l."type" = 'hash'`),
		query('Insert into legacy_zset', pool, `INSERT INTO "legacy_zset" ("_key", "value", "score")
SELECT l."_key", o."data"->>'value', (o."data"->>'score')::numeric
  FROM "legacy_object" l
 INNER JOIN "objects" o
         ON l."_key" = o."data"->>'_key'
 WHERE l."type" = 'zset'
   AND o."data"->>'value' IS NOT NULL
   AND o."data"->>'score' IS NOT NULL`),
		query('Insert into legacy_set', pool, `INSERT INTO "legacy_set" ("_key", "member")
SELECT l."_key", jsonb_array_elements_text(o."data"->'members')
  FROM "legacy_object" l
 INNER JOIN "objects" o
         ON l."_key" = o."data"->>'_key'
 WHERE l."type" = 'set'`),
		query('Insert into legacy_list', pool, `INSERT INTO "legacy_list" ("_key", "array")
SELECT l."_key", ARRAY(SELECT a.t FROM jsonb_array_elements_text(o."data"->'list') WITH ORDINALITY a(t, i) ORDER BY a.i ASC)
  FROM "legacy_object" l
 INNER JOIN "objects" o
         ON l."_key" = o."data"->>'_key'
 WHERE l."type" = 'list'`),
		query('Insert into legacy_string', pool, `INSERT INTO "legacy_string" ("_key", "data")
SELECT l."_key", CASE
	WHEN o."data" ? 'value' THEN o."data"->>'value'
	ELSE o."data"->>'data'
END
  FROM "legacy_object" l
 INNER JOIN "objects" o
         ON l."_key" = o."data"->>'_key'
 WHERE l."type" = 'string'`)
	]);

	console.timeEnd('Convert');

	await query('Create view legacy_object_live', pool, `CREATE VIEW "legacy_object_live" AS
SELECT "_key", "type"
  FROM "legacy_object"
 WHERE "expireAt" IS NULL
    OR "expireAt" > CURRENT_TIMESTAMP`);

	await transaction('Split imported data', pool, async function(db) {
		await query('Create type legacy_imported_type', db, `CREATE TYPE LEGACY_IMPORTED_TYPE AS ENUM ( 'bookmark', 'category', 'favourite', 'group', 'message', 'post', 'room', 'topic', 'user', 'vote' )`);

		await query('Create table legacy_imported', db, `CREATE TABLE "legacy_imported" (
	"type" LEGACY_IMPORTED_TYPE NOT NULL,
	"id" BIGINT NOT NULL,
	"data" JSONB NOT NULL
)`);

		await query('Insert into legacy_imported', db, `INSERT INTO "legacy_imported" ("type", "id", "data")
SELECT (regexp_match(o."_key", '^_imported_(.*):'))[1]::LEGACY_IMPORTED_TYPE, (regexp_match(o."_key", ':(.*)$'))[1]::BIGINT, h."data"
  FROM "legacy_object_live" o
 INNER JOIN "legacy_hash" h
         ON o."_key" = h."_key"
        AND o."type" = h."type"
 WHERE o."_key" LIKE '_imported_%:%'`);

		await query('Delete from legacy_object', db, `DELETE FROM "legacy_object" o
 USING "legacy_imported" i
 WHERE o."_key" = '_imported_' || i."type" || ':' || i."id"
   AND o."type" = 'hash'`);
	});

	console.time('Constraints');

	await Promise.all([
		async function() {
			await query('Add primary key to legacy_hash', pool, `ALTER TABLE "legacy_hash"
	ADD PRIMARY KEY ("_key")`);

			await query('Add foreign key to legacy_hash', pool, `ALTER TABLE "legacy_hash"
	ADD CONSTRAINT "fk__legacy_hash__key"
	FOREIGN KEY ("_key", "type")
	REFERENCES "legacy_object"("_key", "type")
	ON UPDATE CASCADE
	ON DELETE CASCADE`);
		}(),
		async function() {
			await query('Add primary key to legacy_zset', pool, `ALTER TABLE "legacy_zset"
	ADD PRIMARY KEY ("_key", "value")`);

			await query('Add foreign key to legacy_zset', pool, `ALTER TABLE "legacy_zset"
	ADD CONSTRAINT "fk__legacy_zset__key"
	FOREIGN KEY ("_key", "type")
	REFERENCES "legacy_object"("_key", "type")
	ON UPDATE CASCADE
	ON DELETE CASCADE`);

			await query('Create index on key__score', pool, `CREATE INDEX "idx__legacy_zset__key__score" ON "legacy_zset"("_key" ASC, "score" DESC)`);
		}(),
		async function() {
			await query('Add primary key to legacy_set', pool, `ALTER TABLE "legacy_set"
	ADD PRIMARY KEY ("_key", "member")`);

			await query('Add foreign key to legacy_set', pool, `ALTER TABLE "legacy_set"
	ADD CONSTRAINT "fk__legacy_set__key"
	FOREIGN KEY ("_key", "type")
	REFERENCES "legacy_object"("_key", "type")
	ON UPDATE CASCADE
	ON DELETE CASCADE`);
		}(),
		async function() {
			await query('Add primary key to legacy_list', pool, `ALTER TABLE "legacy_list"
	ADD PRIMARY KEY ("_key")`);

			await query('Add foreign key to legacy_list', pool, `ALTER TABLE "legacy_list"
	ADD CONSTRAINT "fk__legacy_list__key"
	FOREIGN KEY ("_key", "type")
	REFERENCES "legacy_object"("_key", "type")
	ON UPDATE CASCADE
	ON DELETE CASCADE`);
		}(),
		async function() {
			await query('Add primary key to legacy_string', pool, `ALTER TABLE "legacy_string"
	ADD PRIMARY KEY ("_key")`);

			await query('Add foreign key to legacy_string', pool, `ALTER TABLE "legacy_string"
	ADD CONSTRAINT "fk__legacy_string__key"
	FOREIGN KEY ("_key", "type")
	REFERENCES "legacy_object"("_key", "type")
	ON UPDATE CASCADE
	ON DELETE CASCADE`);
		}(),
		async function() {
			await query('Add primary key to legacy_imported', pool, `ALTER TABLE "legacy_imported"
	ADD PRIMARY KEY ("type", "id")`);
		}()
	]);

	console.timeEnd('Constraints');

	console.time('Cleanup');

	await Promise.all([
		query('Drop table objects', pool, `DROP TABLE "objects" CASCADE`),
		query('Drop temporary index on legacy_objects', pool, `DROP INDEX "idx__legacy_object__type"`)
	]);

	console.timeEnd('Cleanup');

	await query('Alter tables cluster on', pool, `ALTER TABLE "legacy_object" CLUSTER ON "legacy_object_pkey";
ALTER TABLE "legacy_hash" CLUSTER ON "legacy_hash_pkey";
ALTER TABLE "legacy_zset" CLUSTER ON "legacy_zset_pkey";
ALTER TABLE "legacy_set" CLUSTER ON "legacy_set_pkey";
ALTER TABLE "legacy_list" CLUSTER ON "legacy_list_pkey";
ALTER TABLE "legacy_string" CLUSTER ON "legacy_string_pkey";
ALTER TABLE "legacy_imported" CLUSTER ON "legacy_imported_pkey"`);

	await query('Cluster all tables', pool, `CLUSTER VERBOSE`);

	console.time('Analyze');

	await Promise.all([
		query('Analyze legacy_object', pool, `ANALYZE VERBOSE "legacy_object"`),
		query('Analyze legacy_hash', pool, `ANALYZE VERBOSE "legacy_hash"`),
		query('Analyze legacy_zset', pool, `ANALYZE VERBOSE "legacy_zset"`),
		query('Analyze legacy_set', pool, `ANALYZE VERBOSE "legacy_set"`),
		query('Analyze legacy_list', pool, `ANALYZE VERBOSE "legacy_list"`),
		query('Analyze legacy_string', pool, `ANALYZE VERBOSE "legacy_string"`)
	]);

	console.timeEnd('Analyze');

	await pool.end();
}

module.exports = main;
