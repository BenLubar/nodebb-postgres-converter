COPY (
	SELECT "unique_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'ip:recent'
	   AND "type" = 'zset'
) TO '/tmp/ip-hashes';

CREATE TEMPORARY TABLE "broken_ip_hashes" (
	"ip" INET NOT NULL,
	"hash" TEXT COLLATE "C" NOT NULL PRIMARY KEY
) WITHOUT OIDS;

COPY "broken_ip_hashes"
FROM PROGRAM '/tmp/brute_ips';

COPY (SELECT 1)
TO PROGRAM 'rm -f /tmp/ip-hashes /tmp/brute_ips';

CREATE UNLOGGED TABLE "classify"."ip_recent" (
	"ip" INET NOT NULL PRIMARY KEY,
	"last_seen" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

CREATE INDEX ON "classify"."ip_recent"("last_seen" DESC);

ALTER TABLE "classify"."ip_recent" CLUSTER ON "ip_recent_pkey";

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

-- Drop temporary table.
DROP TABLE "broken_ip_hashes";
