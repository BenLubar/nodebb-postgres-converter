CREATE TEMPORARY TABLE "follower_data" ON COMMIT DROP AS
SELECT SPLIT_PART("_key", ':', 2)::BIGINT "uid",
       "unique_string"::BIGINT "follower_id",
       TO_TIMESTAMP("value_numeric" / 1000) "followed_at"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'followers:[0-9]+';

CREATE TEMPORARY TABLE "following_data" ON COMMIT DROP AS
SELECT "unique_string"::BIGINT "uid",
       SPLIT_PART("_key", ':', 2)::BIGINT "follower_id",
       TO_TIMESTAMP("value_numeric" / 1000) "followed_at"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'following:[0-9]+';

ALTER TABLE "follower_data"
	ADD PRIMARY KEY ("uid", "follower_id"),
	CLUSTER ON "follower_data_pkey";

ALTER TABLE "following_data"
	ADD PRIMARY KEY ("uid", "follower_id"),
	CLUSTER ON "following_data_pkey";

ANALYZE "follower_data";
ANALYZE "following_data";

CREATE TABLE "classify"."user_followers" (
	"uid" BIGINT NOT NULL,
	"follower_id" BIGINT NOT NULL,
	"followed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."user_followers"
SELECT COALESCE(fr."uid", fi."uid"),
       COALESCE(fr."follower_id", fi."follower_id"),
       LEAST(fr."followed_at", fi."followed_at")
  FROM "follower_data" fr
  FULL OUTER JOIN "following_data" fi
               ON fr."uid" = fi."uid"
              AND fr."follower_id" = fi."follower_id";

CREATE INDEX ON "classify"."user_followers"("followed_at");
ALTER TABLE "classify"."user_followers"
	ADD PRIMARY KEY ("uid", "follower_id"),
	CLUSTER ON "user_followers_followed_at_idx";
CREATE UNIQUE INDEX ON "classify"."user_followers"("follower_id", "uid");
