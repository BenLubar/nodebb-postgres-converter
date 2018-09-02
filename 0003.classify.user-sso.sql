CREATE TABLE "classify"."user_sso" (
	"uid" BIGINT NOT NULL,
	"plugin" TEXT COLLATE "C" NOT NULL,
	"externalID" TEXT COLLATE "C" NOT NULL,
	"plugin_data" TEXT COLLATE "C",

	PRIMARY KEY ("plugin", "externalID")
) WITHOUT OIDS;

CREATE INDEX ON "classify"."user_sso"("uid");

ALTER TABLE "classify"."user_sso" CLUSTER ON "user_sso_pkey";

INSERT INTO "classify"."user_sso"
SELECT "value_string"::BIGINT,
       'nodebb-plugin-sso-facebook',
       "unique_string",
       "classify"."get_hash_string"('user:' || "value_string", 'fbaccesstoken')
  FROM "classify"."unclassified"
 WHERE "_key" = 'fbid:uid'
   AND "type" = 'hash'
UNION ALL
SELECT "value_string"::BIGINT,
       'nodebb-plugin-sso-github',
       "unique_string",
       NULL
  FROM "classify"."unclassified"
 WHERE "_key" = 'githubid:uid'
   AND "type" = 'hash'
UNION ALL
SELECT "value_string"::BIGINT,
       'nodebb-plugin-sso-google',
       "unique_string",
       NULL
  FROM "classify"."unclassified"
 WHERE "_key" = 'gplusid:uid'
   AND "type" = 'hash'
UNION ALL
SELECT "value_string"::BIGINT,
       'nodebb-plugin-sso-twitter',
       "unique_string",
       NULL
  FROM "classify"."unclassified"
 WHERE "_key" = 'twid:uid'
   AND "type" = 'hash';
