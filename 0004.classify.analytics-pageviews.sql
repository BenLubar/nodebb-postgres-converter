CREATE TYPE "classify"."analytics_pageview_category" AS ENUM (
	'none',
	'bot',
	'guest',
	'registered'
);

CREATE TABLE "classify"."analytics_pageviews" (
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0,
	"category" "classify"."analytics_pageview_category" NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."analytics_pageviews"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT,
       'none'
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:pageviews'
   AND "type" = 'zset';

WITH "categories" ("category") AS (VALUES ('bot'), ('guest'), ('registered'))
INSERT INTO "classify"."analytics_pageviews"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT,
       "category"::"classify"."analytics_pageview_category"
  FROM "categories"
 INNER JOIN "classify"."unclassified"
         ON "_key" = 'analytics:pageviews:' || "category"
        AND "type" = 'zset';

ALTER TABLE "classify"."analytics_pageviews"
	ADD PRIMARY KEY ("hour", "category"),
	CLUSTER ON "analytics_pageviews_pkey";

CREATE VIEW "classify"."analytics_pageviews_month" AS
SELECT CAST(DATE_TRUNC('month', "hour") AS DATE) "month",
       SUM("count") "count",
       "category"
  FROM "classify"."analytics_pageviews"
 GROUP BY CAST(DATE_TRUNC('month', "hour") AS DATE),
          "category";
