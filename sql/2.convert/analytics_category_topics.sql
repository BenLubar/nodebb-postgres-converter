CREATE TABLE "analytics_category_topics" (
	"cid" bigint NOT NULL,
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_category_topics" SELECT
       i."value"::bigint "cid",
       to_timestamp(t."value"::double precision / 1000) "timestamp",
       t."score"::bigint "count"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" t
    ON t."key0" = 'analytics'
   AND t."key1" = ARRAY['topics', 'byCid', i."value"]
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

ALTER TABLE "analytics_category_topics" ADD PRIMARY KEY ("cid", "timestamp");

ALTER TABLE "analytics_category_topics"
      CLUSTER ON "analytics_category_topics_pkey";
