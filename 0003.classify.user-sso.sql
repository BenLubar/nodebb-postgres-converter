CREATE UNLOGGED TABLE "classify"."user_sso" (
	"uid" BIGINT NOT NULL,
	"plugin" TEXT COLLATE "C" NOT NULL,
	"externalID" BIGINT NOT NULL,
	"plugin_data" TEXT COLLATE "C",

	PRIMARY KEY ("plugin", "externalID")
) WITHOUT OIDS;

CREATE INDEX ON "classify"."user_sso"("uid");

ALTER TABLE "classify"."user_sso" CLUSTER ON "user_sso_pkey";

WITH uids AS (
	SELECT "value_numeric"::BIGINT "uid",
	       'user:' || "value_numeric" "key"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'username:uid'
	   AND "type" = 'zset'
)
INSERT INTO "classify"."user_sso"
SELECT "uid",
       'nodebb-plugin-sso-facebook',
       "classify"."get_hash_int"("key", 'fbid'),
       "classify"."get_hash_string"("key", 'fbaccesstoken')
  FROM uids
 WHERE "classify"."get_hash_int"("key", 'fbid') IS NOT NULL
UNION ALL
SELECT "uid",
       'nodebb-plugin-sso-github',
       "classify"."get_hash_int"("key", 'githubid'),
       NULL
  FROM uids
 WHERE "classify"."get_hash_int"("key", 'githubid') IS NOT NULL
UNION ALL
SELECT "uid",
       'nodebb-plugin-sso-google',
       "classify"."get_hash_int"("key", 'gplusid'),
       NULL
  FROM uids
 WHERE "classify"."get_hash_int"("key", 'gplusid') IS NOT NULL
UNION ALL
SELECT "uid",
       'nodebb-plugin-sso-twitter',
       "classify"."get_hash_int"("key", 'twid'),
       NULL
  FROM uids
 WHERE "classify"."get_hash_int"("key", 'twid') IS NOT NULL;
