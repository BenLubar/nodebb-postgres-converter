CREATE TABLE "classify"."errors_404" (
	"path" TEXT COLLATE "C" NOT NULL,
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

INSERT INTO "classify"."errors_404"
SELECT "unique_string",
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'errors:404'
   AND "type" = 'zset';

ALTER TABLE "classify"."errors_404"
	ADD PRIMARY KEY ("path"),
	CLUSTER ON "errors_404_pkey";
