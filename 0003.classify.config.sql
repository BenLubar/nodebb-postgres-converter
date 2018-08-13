CREATE UNLOGGED TABLE "classify"."config" (
	"key" TEXT COLLATE "C" NOT NULL PRIMARY KEY,
	"value" TEXT COLLATE "C" NOT NULL
) WITHOUT OIDS;

ALTER TABLE "classify"."config" CLUSTER ON "config_pkey";

INSERT INTO "classify"."config"
SELECT "unique_string", "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" = 'config'
   AND "type" = 'hash'
UNION ALL
SELECT 'ip-blacklist-rules', "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" = 'ip-blacklist-rules'
   AND "type" = 'hash'
   AND "unique_string" = 'rules';
