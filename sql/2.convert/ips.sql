CREATE TABLE "ips" (
	"ip" inet NOT NULL,
	"last_seen" timestamptz NOT NULL DEFAULT NOW()
);

CREATE FUNCTION pg_temp.try_parse_inet(text) RETURNS inet AS $$
BEGIN
	RETURN $1::inet;
EXCEPTION WHEN OTHERS THEN
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

INSERT INTO "ips" SELECT
       pg_temp.try_parse_inet(r."value") "ip",
       to_timestamp(r."score"::double precision / 1000) "last_seen"
  FROM "objects_legacy" r
 WHERE r."key0" = 'ip'
   AND r."key1" = ARRAY['recent']
   AND pg_temp.try_parse_inet(r."value") IS NOT NULL;

DROP FUNCTION pg_temp.try_parse_inet(text);

ALTER TABLE "ips" ADD PRIMARY KEY ("ip");

CLUSTER "ips" USING "ips_pkey";

CREATE INDEX "idx__ips__last_seen" ON "ips"("last_seen" DESC);

ANALYZE "ips";
