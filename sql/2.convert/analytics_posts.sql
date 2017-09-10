CREATE TABLE "analytics_posts" (
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
);

INSERT INTO "analytics_posts" SELECT
       to_timestamp(p."value"::double precision / 1000) "timestamp",
       p."score"::bigint "count"
  FROM "objects_legacy" p
 WHERE p."key0" = 'analytics'
   AND p."key1" = ARRAY['posts'];

ALTER TABLE "analytics_posts" ADD PRIMARY KEY ("timestamp");

ALTER TABLE "analytics_posts"
      CLUSTER ON "analytics_posts_pkey";
