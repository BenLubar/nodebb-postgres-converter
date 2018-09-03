CREATE TABLE "classify"."analytics_flags" (
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

INSERT INTO "classify"."analytics_flags"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:flags'
   AND "type" = 'zset';

ALTER TABLE "classify"."analytics_flags"
	ADD PRIMARY KEY ("hour"),
	CLUSTER ON "analytics_flags_pkey";
