CREATE TABLE "analytics_errors" (
	"code" int NOT NULL,
	"timestamp" timestamptz NOT NULL CHECK (date_trunc('hour', "timestamp") = "timestamp"),
	"count" bigint NOT NULL DEFAULT 0
) WITH (autovacuum_enabled = false);

INSERT INTO "analytics_errors" SELECT
       c.c "code",
       to_timestamp(e."value"::double precision / 1000) "timestamp",
       e."score"::bigint "count"
  FROM (VALUES (404::int), (503::int)) c(c)
 INNER JOIN "objects_legacy" e
    ON e."key0" = 'analytics'
   AND e."key1" = ARRAY['errors', c.c::text];

ALTER TABLE "analytics_errors" ADD PRIMARY KEY ("code", "timestamp");

ALTER TABLE "analytics_errors"
      CLUSTER ON "analytics_errors_pkey";
