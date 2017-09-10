CREATE TABLE "user_ips" (
	"uid" bigint NOT NULL,
	"ip" inet NOT NULL,
	"last_seen" timestamptz NOT NULL DEFAULT NOW()
) WITH (autovacuum_enabled = false);

CREATE FUNCTION pg_temp.try_parse_inet(text) RETURNS inet AS $$
BEGIN
	RETURN $1::inet;
EXCEPTION WHEN OTHERS THEN
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

INSERT INTO "user_ips" SELECT
       i."score"::bigint "uid",
       pg_temp.try_parse_inet(u."value") "ip",
       to_timestamp(u."score"::double precision / 1000) "last_seen"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" u
    ON u."key0" = 'uid'
   AND u."key1" = ARRAY[i."score"::text, 'ip']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND pg_temp.try_parse_inet(u."value") IS NOT NULL;

DROP FUNCTION pg_temp.try_parse_inet(text);

ALTER TABLE "user_ips" ADD PRIMARY KEY ("uid", "ip");

CREATE INDEX "idx__user_ips__last_seen" ON "user_ips"("last_seen" DESC);

CREATE INDEX "idx__user_ips__ip__last_seen" ON "user_ips"("ip", "last_seen" DESC);

ALTER TABLE "user_ips"
      CLUSTER ON "user_ips_pkey";
