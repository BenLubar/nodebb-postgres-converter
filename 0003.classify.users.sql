CREATE TYPE "classify".USER_ONLINE_STATUS AS ENUM (
	'offline',
	'online',
	'away',
	'dnd'
);

CREATE TABLE "classify"."users" (
	-- account
	"uid" BIGSERIAL NOT NULL PRIMARY KEY,
	"username" TEXT COLLATE "C" NOT NULL,
	"userslug" TEXT COLLATE "C" NOT NULL,
	"email" TEXT COLLATE "C",
	"email:confirmed" BOOLEAN NOT NULL DEFAULT FALSE,
	"password" TEXT COLLATE "C",
	"passwordExpiry" TIMESTAMPTZ,

	-- metadata
	"joindate" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"lastonline" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"lastposttime" TIMESTAMPTZ,
	"lastqueuetime" TIMESTAMPTZ,
	"rss_token" UUID,
	"acceptTos" BOOLEAN NOT NULL DEFAULT FALSE,
	"gdpr_consent" BOOLEAN NOT NULL DEFAULT FALSE,
	"reputation" BIGINT NOT NULL DEFAULT 0,

	-- moderation
	"banned" BOOLEAN NOT NULL DEFAULT FALSE,
	"banned:expire" TIMESTAMPTZ DEFAULT NULL CHECK ("banned" OR "banned:expire" IS NULL),
	"moderationNote" TEXT COLLATE "C" NOT NULL DEFAULT '',

	-- profile
	"fullname" TEXT COLLATE "C",
	"website" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"aboutme" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"location" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"birthday" DATE,
	"showemail" BOOLEAN NOT NULL DEFAULT FALSE,
	"status" "classify".USER_ONLINE_STATUS NOT NULL DEFAULT 'online',
	"signature" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"picture" TEXT COLLATE "C",
	"uploadedpicture" TEXT COLLATE "C",
	"cover:url" TEXT COLLATE "C",
	"cover:position" "classify".COVER_POSITION NOT NULL,
	"groupTitle" TEXT COLLATE "C",

	-- counters/caches
	"profileviews" BIGINT NOT NULL DEFAULT 0,
	"blocksCount" BIGINT NOT NULL DEFAULT 0,
	"postcount" BIGINT NOT NULL DEFAULT 0,
	"topiccount" BIGINT NOT NULL DEFAULT 0,
	"flags" BIGINT NOT NULL DEFAULT 0,
	"followerCount" BIGINT NOT NULL DEFAULT 0,
	"followingCount" BIGINT NOT NULL DEFAULT 0
)
WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."users"("username");
CREATE UNIQUE INDEX ON "classify"."users"("userslug");
CREATE UNIQUE INDEX ON "classify"."users"("email");
CREATE INDEX ON "classify"."users"("joindate");
CREATE INDEX ON "classify"."users"("lastonline");
CREATE INDEX ON "classify"."users"("status", "lastonline");
CREATE INDEX ON "classify"."users"("reputation");

ALTER TABLE "classify"."users" CLUSTER ON "users_pkey";

WITH uids AS (
	SELECT u."value_numeric"::BIGINT "uid",
	       'user:' || u."value_numeric" "key"
	  FROM "classify"."unclassified" u
	 WHERE u."_key" = 'username:uid'
	   AND u."type" = 'zset'
)
INSERT INTO "classify"."users"
SELECT uid,
       "classify"."get_hash_string"(key, 'username'),
       "classify"."get_hash_string"(key, 'userslug'),
       "classify"."get_hash_string"(key, 'email'),
       COALESCE("classify"."get_hash_boolean"(key, 'email:confirmed'), FALSE),
       "classify"."get_hash_string"(key, 'password'),
       "classify"."get_hash_timestamp"(key, 'passwordExpiry'),
       "classify"."get_hash_timestamp"(key, 'joindate'),
       "classify"."get_hash_timestamp"(key, 'lastonline'),
       "classify"."get_hash_timestamp"(key, 'lastposttime'),
       "classify"."get_hash_timestamp"(key, 'lastqueuetime'),
       "classify"."get_hash_string"(key, 'rss_token')::UUID,
       COALESCE("classify"."get_hash_boolean"(key, 'acceptTos'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'gdpr_consent'), FALSE),
       COALESCE("classify"."get_hash_string"(key, 'reputation'), '0')::BIGINT,
       COALESCE("classify"."get_hash_boolean"(key, 'banned'), FALSE),
       "classify"."get_hash_timestamp"(key, 'banned:expire'),
       COALESCE("classify"."get_hash_string"(key, 'moderationNote'), ''),
       "classify"."get_hash_string"(key, 'fullname'),
       COALESCE("classify"."get_hash_string"(key, 'website'), ''),
       COALESCE("classify"."get_hash_string"(key, 'aboutme'), ''),
       COALESCE("classify"."get_hash_string"(key, 'location'), ''),
       "classify"."get_hash_date"(key, 'birthday'),
       COALESCE("classify"."get_hash_boolean"(key, 'showemail'), FALSE),
       COALESCE("classify"."get_hash_string"(key, 'status'), 'online')::"classify".USER_ONLINE_STATUS,
       COALESCE("classify"."get_hash_string"(key, 'signature'), ''),
       "classify"."get_hash_string"(key, 'picture'),
       "classify"."get_hash_string"(key, 'uploadedpicture'),
       "classify"."get_hash_string"(key, 'cover:url'),
       "classify"."get_hash_position"(key, 'cover:position'),
       "classify"."get_hash_string"(key, 'groupTitle'),
       COALESCE("classify"."get_hash_int"(key, 'profileviews'), 0),
       COALESCE("classify"."get_hash_int"(key, 'blocksCount'), 0),
       COALESCE("classify"."get_hash_int"(key, 'postcount'), 0),
       COALESCE("classify"."get_hash_int"(key, 'topiccount'), 0),
       COALESCE("classify"."get_hash_int"(key, 'flags'), 0),
       COALESCE("classify"."get_hash_int"(key, 'followerCount'), 0),
       COALESCE("classify"."get_hash_int"(key, 'followingCount'), 0)
  FROM uids;

SELECT setval('classify.users_uid_seq', "classify"."get_hash_string"('global', 'nextUid')::BIGINT);
