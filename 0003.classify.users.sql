CREATE UNLOGGED TABLE "classify"."users" (
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
	"birthday" DATE
)
WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."users"("username");
CREATE UNIQUE INDEX ON "classify"."users"("userslug");
CREATE UNIQUE INDEX ON "classify"."users"("email");
CREATE INDEX ON "classify"."users"("joindate");
CREATE INDEX ON "classify"."users"("lastonline");
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
       "classify"."get_hash_date"(key, 'birthday')
  FROM uids;

SELECT setval('classify.users_uid_seq', "classify"."get_hash_string"('global', 'nextUid')::BIGINT);
