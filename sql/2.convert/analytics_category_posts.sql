CREATE TABLE "analytics_category_posts" (
	"cid" bigint NOT NULL,
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_category_posts" SELECT
       i."value"::bigint "cid",
       to_timestamp(p."value"::double precision / 1000) "timestamp",
       p."score"::bigint "count"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" p
    ON p."key0" = 'analytics'
   AND p."key1" = ARRAY['posts', 'byCid', i."value"]
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

ALTER TABLE "analytics_category_posts" ADD PRIMARY KEY ("cid", "timestamp");

ALTER TABLE "analytics_category_posts"
      CLUSTER ON "analytics_category_posts_pkey";
