CREATE UNLOGGED TABLE "classify"."analytics_uniquevisitors" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_uniquevisitors" CLUSTER ON "analytics_uniquevisitors_pkey";

INSERT INTO "classify"."analytics_uniquevisitors"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:uniquevisitors'
   AND "type" = 'zset';
