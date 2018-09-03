CREATE TABLE "classify"."analytics_uniquevisitors" (
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

INSERT INTO "classify"."analytics_uniquevisitors"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:uniquevisitors'
   AND "type" = 'zset';

ALTER TABLE "classify"."analytics_uniquevisitors"
	ADD PRIMARY KEY ("hour"),
	CLUSTER ON "analytics_uniquevisitors_pkey";
