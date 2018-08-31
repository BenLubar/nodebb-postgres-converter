CREATE UNLOGGED TABLE "classify"."errors_404" (
	"path" TEXT COLLATE "C" NOT NULL PRIMARY KEY,
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."errors_404" CLUSTER ON "errors_404_pkey";

INSERT INTO "classify"."errors_404"
SELECT "unique_string",
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'errors:404'
   AND "type" = 'zset';
