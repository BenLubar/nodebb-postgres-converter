CREATE TABLE "classify"."ip_user" (
	"uid" BIGINT NOT NULL,
	"ip" INET NOT NULL,
	"last_seen" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."ip_user"
SELECT "unique_string"::BIGINT,
       SPLIT_PART(REPLACE("_key", '::ffff:', ''), ':', 2)::INET,
       TO_TIMESTAMP("value_numeric" / 1000)
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'ip:%:uid'
   AND "type" = 'zset';

ALTER TABLE "classify"."ip_user"
	ADD PRIMARY KEY ("uid", "ip"),
	CLUSTER ON "ip_user_pkey";
CREATE INDEX ON "classify"."ip_user"("ip", "uid");
CREATE INDEX ON "classify"."ip_user"("last_seen" DESC);
