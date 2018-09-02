CREATE TABLE "classify"."config" (
	"plugin" TEXT COLLATE "C" NOT NULL,
	"key" TEXT COLLATE "C" NOT NULL,
	"value" TEXT COLLATE "C" NOT NULL,

	PRIMARY KEY ("plugin", "key")
) WITHOUT OIDS;

ALTER TABLE "classify"."config" CLUSTER ON "config_pkey";

INSERT INTO "classify"."config"
SELECT '', "unique_string", "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" = 'config'
   AND "type" = 'hash'
UNION ALL
SELECT '', 'ip-blacklist-rules', "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" = 'ip-blacklist-rules'
   AND "type" = 'hash'
   AND "unique_string" = 'rules'
UNION ALL
SELECT SUBSTRING("_key" FROM LENGTH('settings:') + 1), "unique_string", "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'settings:%'
   AND "type" = 'hash';
