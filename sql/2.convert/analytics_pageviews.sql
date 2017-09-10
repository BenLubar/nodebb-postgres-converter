CREATE TABLE "analytics_pageviews" (
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
);

INSERT INTO "analytics_pageviews" SELECT
       to_timestamp(v."value"::double precision / 1000) "timestamp",
       v."score"::bigint "count"
  FROM "objects_legacy" v
 WHERE v."key0" = 'analytics'
   AND v."key1" = ARRAY['pageviews'];

ALTER TABLE "analytics_pageviews" ADD PRIMARY KEY ("timestamp");

ALTER TABLE "analytics_pageviews"
      CLUSTER ON "analytics_pageviews_pkey";

CREATE VIEW "analytics_pageviews_month" AS SELECT
       date_trunc('month', "timestamp") "timestamp",
       SUM("count") "count"
  FROM "analytics_pageviews"
 GROUP BY date_trunc('month', "timestamp");
