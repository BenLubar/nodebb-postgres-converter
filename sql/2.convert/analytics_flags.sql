CREATE TABLE "analytics_flags" (
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
);

INSERT INTO "analytics_flags" SELECT
       to_timestamp(f."value"::double precision / 1000) "timestamp",
       f."score"::bigint "count"
  FROM "objects_legacy" f
 WHERE f."key0" = 'analytics'
   AND f."key1" = ARRAY['flags'];

ALTER TABLE "analytics_flags" ADD PRIMARY KEY ("timestamp");

ALTER TABLE "analytics_flags"
      CLUSTER ON "analytics_flags_pkey";
