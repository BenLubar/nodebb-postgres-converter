CREATE TABLE "user_ips" (
	"uid" bigint NOT NULL,
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

INSERT INTO "user_ips" SELECT
       i."value"::bigint "uid",
       pg_temp.try_parse_inet(r."value") "ip",
       to_timestamp(i."score"::double precision / 1000) "last_seen"
  FROM "objects_legacy" r
 INNER JOIN "objects_legacy" i
    ON i."key0" = 'ip'
   AND i."key1" = string_to_array(r."value", ':') || ARRAY['uid']
 WHERE r."key0" = 'ip'
   AND r."key1" = ARRAY['recent']
   AND pg_temp.try_parse_inet(r."value") IS NOT NULL;

DROP FUNCTION pg_temp.try_parse_inet(text);

ALTER TABLE "user_ips" ADD PRIMARY KEY ("uid", "ip");

CLUSTER "user_ips" USING "user_ips_pkey";

CREATE INDEX "idx__user_ips__last_seen" ON "user_ips"("last_seen" DESC);

CREATE INDEX "idx__user_ips__ip__last_seen" ON "user_ips"("ip", "last_seen" DESC);

ANALYZE "user_ips";
