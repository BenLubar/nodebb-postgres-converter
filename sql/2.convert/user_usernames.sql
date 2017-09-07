CREATE TABLE "user_usernames" (
	"uid" bigint NOT NULL,
	"username" text NOT NULL,
	"changed_at" timestamptz NOT NULL DEFAULT NOW()
);

INSERT INTO "user_usernames" SELECT
       i."score"::bigint "uid",
       trim(TRAILING ':' FROM trim(TRAILING '0123456789' FROM u."value")) "username",
       to_timestamp(u."score"::double precision / 1000) "changed_at"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" u
    ON u."key0" = 'user'
   AND u."key1" = ARRAY[i."score"::text, 'usernames']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid'];

CREATE INDEX "idx__user_usernames__uid__changed_at" ON "user_usernames"("uid", "changed_at" DESC);

CLUSTER "user_usernames" USING "idx__user_usernames__uid__changed_at";

CREATE INDEX "idx__user_usernames__username" ON "user_usernames"("username");

ANALYZE "user_usernames";
