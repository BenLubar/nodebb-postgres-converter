CREATE TABLE "analytics_topics" (
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_topics" SELECT
       to_timestamp(t."value"::double precision / 1000) "timestamp",
       t."score"::bigint "count"
  FROM "objects_legacy" t
 WHERE t."key0" = 'analytics'
   AND t."key1" = ARRAY['topics'];

ALTER TABLE "analytics_topics" ADD PRIMARY KEY ("timestamp");

ALTER TABLE "analytics_topics"
      CLUSTER ON "analytics_topics_pkey";
