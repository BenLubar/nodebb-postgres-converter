CREATE TABLE "classify"."user_sso" (
	"uid" BIGINT NOT NULL,
	"plugin" TEXT COLLATE "C" NOT NULL,
	"externalID" TEXT COLLATE "C" NOT NULL,
	"plugin_data" TEXT COLLATE "C"
) WITHOUT OIDS;

INSERT INTO "classify"."user_sso"
SELECT id."value_string"::BIGINT,
       'nodebb-plugin-sso-facebook',
       id."unique_string",
       at."value_string"
  FROM "classify"."unclassified" id
  LEFT JOIN "classify"."unclassified" at
         ON at."_key" = 'user:' || id."value_string"
        AND at."type" = 'hash'
        AND at."unique_string" = 'fbaccesstoken'
 WHERE id."_key" = 'fbid:uid'
   AND id."type" = 'hash'
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

ALTER TABLE "classify"."user_sso"
	ADD PRIMARY KEY ("plugin", "externalID"),
	CLUSTER ON "user_sso_pkey";
CREATE INDEX ON "classify"."user_sso"("uid");
