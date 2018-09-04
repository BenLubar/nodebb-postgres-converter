CREATE TABLE "classify"."user_bans" (
	"ban_id" BIGSERIAL NOT NULL,
	"uid" BIGINT NOT NULL,
	"banned_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"expires_at" TIMESTAMPTZ CHECK ("expires_at" IS NULL OR "expires_at" > "banned_at"),
	"reason" TEXT COLLATE "C"
) WITHOUT OIDS;

INSERT INTO "classify"."user_bans"
SELECT NEXTVAL('classify.user_bans_ban_id_seq'::REGCLASS),
       SPLIT_PART(COALESCE(ban."_key", reason."_key"), ':', 2)::BIGINT,
       TO_TIMESTAMP(COALESCE(ban."value_numeric", reason."value_numeric") / 1000),
       TO_TIMESTAMP(NULLIF(ban."unique_string", '0')::NUMERIC / 1000),
       NULLIF(reason."unique_string", '')
  FROM "classify"."unclassified" ban
  FULL OUTER JOIN "classify"."unclassified" reason
               ON SPLIT_PART(ban."_key", ':', 2) = SPLIT_PART(reason."_key", ':', 2)
              AND ban."value_numeric" = reason."value_numeric"
 WHERE (ban."_key" IS NULL
        OR (ban."_key" SIMILAR TO 'uid:[0-9]+:bans'
       AND ban."type" = 'zset'))
   AND (reason."_key" IS NULL
        OR (reason."_key" SIMILAR TO 'banned:[0-9]+:reasons'
       AND reason."type" = 'zset'));

ALTER TABLE "classify"."user_bans"
	ADD PRIMARY KEY ("ban_id"),
	CLUSTER ON "user_bans_pkey";
CREATE INDEX ON "classify"."user_bans"("uid", "banned_at");
