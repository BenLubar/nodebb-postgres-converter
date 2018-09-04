CREATE TABLE "classify"."user_bans" (
	"ban_id" BIGSERIAL NOT NULL,
	"uid" BIGINT NOT NULL,
	"banned_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"expires_at" TIMESTAMPTZ CHECK ("expires_at" IS NULL OR "expires_at" > "banned_at"),
	"reason" TEXT COLLATE "C"
) WITHOUT OIDS;

INSERT INTO "classify"."user_bans"
SELECT NEXTVAL('classify.user_bans_ban_id_seq'::REGCLASS),
       COALESCE(bans."uid", reasons."uid"),
       COALESCE(bans."banned_at", reasons."banned_at"),
       bans."expires_at",
       reasons."reason"
  FROM (SELECT SPLIT_PART("_key", ':', 2)::BIGINT "uid",
               TO_TIMESTAMP("value_numeric" / 1000) "banned_at",
               CASE WHEN "unique_string" = '0'
                    THEN NULL
                    WHEN "unique_string"::NUMERIC < "value_numeric"
                    THEN TO_TIMESTAMP(("value_numeric" + 1) / 1000)
                    WHEN ("unique_string"::NUMERIC - "value_numeric") > EXTRACT(EPOCH FROM INTERVAL '100 years') * 1000
                    THEN NULL
                    ELSE TO_TIMESTAMP("unique_string"::NUMERIC / 1000)
                     END "expires_at"
          FROM "classify"."unclassified"
         WHERE "_key" SIMILAR TO 'uid:[0-9]+:bans'
           AND "type" = 'zset') bans
  FULL OUTER JOIN (
        SELECT SPLIT_PART("_key", ':', 2)::BIGINT "uid",
               TO_TIMESTAMP("value_numeric" / 1000) "banned_at",
               NULLIF("unique_string", '') "reason"
          FROM "classify"."unclassified"
         WHERE "_key" SIMILAR TO 'banned:[0-9]+:reasons'
           AND "type" = 'zset') reasons
    ON bans."uid" = reasons."uid"
   AND bans."banned_at" = reasons."banned_at"
 ORDER BY COALESCE(bans."banned_at", reasons."banned_at") ASC;

ALTER TABLE "classify"."user_bans"
	ADD PRIMARY KEY ("ban_id"),
	CLUSTER ON "user_bans_pkey";
CREATE INDEX ON "classify"."user_bans"("uid", "banned_at");
