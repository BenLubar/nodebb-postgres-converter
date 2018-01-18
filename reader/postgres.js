'use strict';

const { Client } = require('pg');
const QueryStream = require('pg-query-stream');
const { Transform } = require('stream');

module.exports = async function(connection, count, each) {
	const client = new Client({
		connectionString: connection
	});
	await client.connect();

	try {
		var getAllQuery = `SELECT "data" FROM "objects"`;
		var res;

		try {
			res = await client.query(`SELECT COUNT(*) c FROM "objects"`);
		} catch (ex) {
			getAllQuery = `WITH o AS (SELECT CASE
	WHEN o."expireAt" IS NULL THEN jsonb_build_object('_key', o."_key")
	ELSE jsonb_build_object('_key', o."_key", 'expireAt', EXTRACT(EPOCH FROM o."expireAt") * 1000)
END "data", o."_key", o."type"
  FROM "legacy_object" o)
SELECT h."data" || o."data" "data"
  FROM "legacy_hash" h
 INNER JOIN o
         ON o."_key" = h."_key"
	AND o."type" = h."type"
UNION ALL
SELECT jsonb_build_object('value', z."value", 'score', z."score") || o."data" "data"
  FROM "legacy_zset" z
 INNER JOIN o
         ON o."_key" = z."_key"
	AND o."type" = z."type"
UNION ALL
SELECT jsonb_build_object('members', to_jsonb(array_agg(s."member"))) || o."data" "data"
  FROM "legacy_set" s
 INNER JOIN o
         ON o."_key" = s."_key"
	AND o."type" = s."type"
 GROUP BY o."data"
UNION ALL
SELECT jsonb_build_object('array', to_jsonb(l."array")) || o."data" "data"
  FROM "legacy_list" l
 INNER JOIN o
         ON o."_key" = l."_key"
	AND o."type" = l."type"
UNION ALL
SELECT jsonb_build_object('data', s."data") || o."data" "data"
  FROM "legacy_string" s
 INNER JOIN o
         ON o."_key" = s."_key"
	AND o."type" = s."type"`;
			try {
				res = await client.query(`SELECT (SELECT COUNT(*) FROM "legacy_object" WHERE "type" <> 'zset') + (SELECT COUNT(*) FROM "legacy_zset") + (SELECT COUNT(*) FROM "legacy_imported") c`);
				getAllQuery += `
UNION ALL
SELECT i."data" || jsonb_build_object('_key', '_imported_' || i."type" || ':' || i."id") "data"
  FROM "legacy_imported" i`;
			} catch (ex) {
				res = await client.query(`SELECT (SELECT COUNT(*) FROM "legacy_object" WHERE "type" <> 'zset') + (SELECT COUNT(*) FROM "legacy_zset") c`);
			}
		}

		await count(res.rows[0].c);

		const stream = client.query(new QueryStream(getAllQuery));
		const reader = new Transform({
			transform(chunk, encoding, callback) {
				each(chunk.data).then(callback);
			}
		});

		stream.pipe(reader);

		try {
			await new Promise(function(resolve, reject) {
				reader.on('end', resolve);
				reader.on('error', reject);
			});
		} finally {
			stream.close();
		}
	} finally {
		await client.end();
	}
};
