CREATE UNLOGGED TABLE "classify"."analytics_pageviews_byCid" (
	"cid" BIGINT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0,

	PRIMARY KEY ("cid", "hour")
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_pageviews_byCid" CLUSTER ON "analytics_pageviews_byCid_pkey";

INSERT INTO "classify"."analytics_pageviews_byCid"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:pageviews:byCid:') + 1)::BIGINT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:pageviews:byCid:%'
   AND "type" = 'zset';
