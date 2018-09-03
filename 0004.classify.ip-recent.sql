CREATE TEMPORARY TABLE "broken_ip_hashes" (
	"ip" INET NOT NULL,
	"hash" TEXT COLLATE "C" NOT NULL PRIMARY KEY
) WITHOUT OIDS
ON COMMIT DROP;

DO $$
BEGIN

IF EXISTS(SELECT 1
            FROM INFORMATION_SCHEMA.TABLES
           WHERE table_schema = 'public'
             AND table_name = 'wtdwtf_real_ip') THEN

INSERT INTO "broken_ip_hashes"
SELECT "ip", ENCODE("hash", 'hex')
  FROM "public"."wtdwtf_real_ip";

END IF;

END;
$$ LANGUAGE plpgsql;

COPY (
	SELECT "unique_string"
	  FROM "classify"."unclassified"
	  LEFT JOIN "broken_ip_hashes"
	         ON "hash" = "unique_string"
	 WHERE "_key" = 'ip:recent'
	   AND "type" = 'zset'
	   AND "hash" IS NULL
) TO '/tmp/ip-hashes';


COPY "broken_ip_hashes"
FROM PROGRAM '/tmp/brute_ips';

COPY (SELECT 1)
TO PROGRAM 'rm -f /tmp/ip-hashes /tmp/brute_ips';

CREATE TABLE "classify"."ip_recent" (
	"ip" INET NOT NULL,
	"last_seen" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."ip_recent"
SELECT bih."ip",
       MAX(TO_TIMESTAMP(uc."value_numeric" / 1000))
  FROM "classify"."unclassified" uc
 INNER JOIN "broken_ip_hashes" bih
         ON uc."unique_string" = bih."hash"
 WHERE uc."_key" = 'ip:recent'
   AND uc."type" = 'zset'
   AND bih."ip" <> '0.0.0.0'
 GROUP BY bih."ip";

ALTER TABLE "classify"."ip_recent"
	ADD PRIMARY KEY ("ip"),
	CLUSTER ON "ip_recent_pkey";
CREATE INDEX ON "classify"."ip_recent"("last_seen" DESC);

-- Delete is included in this step instead of step 4 because it requires access to the temporary data.

-- Merged entries use the latest timestamp.
DELETE FROM "classify"."unclassified" uc
 USING "classify"."ip_recent" ir
 INNER JOIN "broken_ip_hashes" bih
         ON ir."ip" = bih."ip"
 WHERE uc."_key" = 'ip:recent'
   AND uc."type" = 'zset'
   AND uc."unique_string" = bih."hash"
   AND uc."value_numeric" <= (EXTRACT(EPOCH FROM ir."last_seen") * 1000)::NUMERIC;

-- Delete bad hashes without checking timestamps.
DELETE FROM "classify"."unclassified" uc
 USING "broken_ip_hashes" bih
 WHERE uc."_key" = 'ip:recent'
   AND uc."type" = 'zset'
   AND uc."unique_string" = bih."hash"
   AND bih."ip" = '0.0.0.0';
