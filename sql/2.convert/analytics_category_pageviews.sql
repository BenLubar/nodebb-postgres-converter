CREATE TABLE "analytics_category_pageviews" (
	"cid" bigint NOT NULL,
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_category_pageviews" SELECT
       i."value"::bigint "cid",
       to_timestamp(v."value"::double precision / 1000) "timestamp",
       v."score"::bigint "count"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" v
    ON v."key0" = 'analytics'
   AND v."key1" = ARRAY['pageviews', 'byCid', i."value"]
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

ALTER TABLE "analytics_category_pageviews" ADD PRIMARY KEY ("cid", "timestamp");

ALTER TABLE "analytics_category_pageviews"
      CLUSTER ON "analytics_category_pageviews_pkey";
