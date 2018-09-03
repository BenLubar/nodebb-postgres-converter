CREATE TABLE "classify"."analytics_topics_byCid" (
	"cid" BIGINT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

INSERT INTO "classify"."analytics_topics_byCid"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:topics:byCid:') + 1)::BIGINT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:topics:byCid:%'
   AND "type" = 'zset';

ALTER TABLE "classify"."analytics_topics_byCid"
	ADD PRIMARY KEY ("cid", "hour"),
	CLUSTER ON "analytics_topics_byCid_pkey";
