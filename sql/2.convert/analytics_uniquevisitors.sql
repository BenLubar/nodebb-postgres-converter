CREATE TABLE "analytics_uniquevisitors" (
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_uniquevisitors" SELECT
       to_timestamp(v."value"::double precision / 1000) "timestamp",
       v."score"::bigint "count"
  FROM "objects_legacy" v
 WHERE v."key0" = 'analytics'
   AND v."key1" = ARRAY['uniquevisitors'];

ALTER TABLE "analytics_uniquevisitors" ADD PRIMARY KEY ("timestamp");

ALTER TABLE "analytics_uniquevisitors"
      CLUSTER ON "analytics_uniquevisitors_pkey";
