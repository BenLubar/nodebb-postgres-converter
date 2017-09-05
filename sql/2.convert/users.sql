CREATE TABLE "users" (
	"uid" bigserial NOT NULL,
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
);

INSERT INTO "users" SELECT
       (u."data"->>'uid')::bigint "uid",
       u."data" - 'uid' "data"
  FROM "objects_legacy" i,
       "objects_legacy" u
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND u."key0" = 'user'
   AND u."key1" = ARRAY[i."score"::text];

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

CLUSTER "users" USING "users_pkey";

ANALYZE "users";
