CREATE TABLE "users" (
	"uid" bigserial NOT NULL,
	"settings" jsonb NOT NULL DEFAULT '{}',
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- aboutme
	-- banned
	-- banned:expire
	-- birthday
	-- cover:position
	-- cover:url
	-- email
	-- email:confirmed
	-- flags
	-- followerCount
	-- followingCount
	-- fullname
	-- groupTitle
	-- joindate
	-- lastonline
	-- lastposttime
	-- location
	-- moderationNote
	-- password
	-- passwordExpiry
	-- picture
	-- postcount
	-- profileviews
	-- reputation
	-- rss_token
	-- showemail
	-- signature
	-- status
	-- topiccount
	-- uploadedpicture
	-- username
	-- userslug
	-- website
) WITH (autovacuum_enabled = false);

INSERT INTO "users" SELECT
       (u."data"->>'uid')::bigint "uid",
       COALESCE(s."data", '{}') "settings",
       u."data" - 'uid' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" u
    ON u."key0" = 'user'
   AND u."key1" = ARRAY[i."score"::text]
  LEFT OUTER JOIN "objects_legacy" s
    ON s."key0" = 'user'
   AND s."key1" = ARRAY[i."score"::text, 'settings']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid'];

DO $$
DECLARE
	"nextUid" bigint;
BEGIN
	SELECT "data"->>'nextUid' INTO "nextUid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "users_uid_seq" RESTART WITH ' || ("nextUid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "users" ADD PRIMARY KEY ("uid");

ALTER TABLE "users"
      CLUSTER ON "users_pkey";
