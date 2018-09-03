CREATE TEMPORARY TABLE "user_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('user:') + 1)::BIGINT "uid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'user:[0-9]+'
   AND "type" = 'hash';

ALTER TABLE "user_data"
	ADD PRIMARY KEY ("uid", "field"),
	CLUSTER ON "user_data_pkey";

ANALYZE "user_data";

CREATE TYPE "classify".USER_ONLINE_STATUS AS ENUM (
	'offline',
	'online',
	'away',
	'dnd'
);

CREATE TABLE "classify"."users" (
	-- account
	"uid" BIGSERIAL NOT NULL,
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

INSERT INTO "classify"."users"
SELECT uid."value_numeric"::BIGINT,
       username."value",
       userslug."value",
       NULLIF(email."value", ''),
       COALESCE(NULLIF(emailconfirmed."value", ''), '0') = '1',
       password."value",
       TO_TIMESTAMP(NULLIF(NULLIF(passwordExpiry."value", ''), '0')::NUMERIC / 1000),
       TO_TIMESTAMP(joindate."value"::NUMERIC / 1000),
       TO_TIMESTAMP(NULLIF(NULLIF(lastonline."value", ''), '0')::NUMERIC / 1000),
       TO_TIMESTAMP(NULLIF(NULLIF(lastposttime."value", ''), '0')::NUMERIC / 1000),
       TO_TIMESTAMP(NULLIF(NULLIF(lastqueuetime."value", ''), '0')::NUMERIC / 1000),
       NULLIF(rss_token."value", '')::UUID,
       COALESCE(NULLIF(acceptTos."value", ''), '0') = '1',
       COALESCE(NULLIF(gdpr_consent."value", ''), '0') = '1',
       COALESCE(NULLIF(reputation."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(banned."value", ''), '0') = '1',
       TO_TIMESTAMP(NULLIF(NULLIF(bannedexpire."value", ''), '0')::NUMERIC / 1000),
       COALESCE(moderationNote."value", ''),
       NULLIF(fullname."value", ''),
       COALESCE(website."value", ''),
       COALESCE(aboutme."value", ''),
       COALESCE(location."value", ''),
       "classify"."try_parse_date"(birthday."value"),
       COALESCE(NULLIF(showemail."value", ''), '0') = '1',
       COALESCE(NULLIF(status."value", ''), 'online')::"classify".USER_ONLINE_STATUS,
       COALESCE(signature."value", ''),
       NULLIF(picture."value", ''),
       NULLIF(uploadedpicture."value", ''),
       NULLIF(coverurl."value", ''),
       "classify"."parse_cover_position"(coverposition."value"),
       NULLIF(groupTitle."value", ''),
       COALESCE(NULLIF(profileviews."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(blocksCount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(postcount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(topiccount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(flags."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(followerCount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(followingCount."value", ''), '0')::BIGINT
  FROM "classify"."unclassified" uid
  LEFT JOIN "user_data" username
         ON username."uid" = uid."value_numeric"::BIGINT
        AND username."field" = 'username'
  LEFT JOIN "user_data" userslug
         ON userslug."uid" = uid."value_numeric"::BIGINT
        AND userslug."field" = 'userslug'
  LEFT JOIN "user_data" email
         ON email."uid" = uid."value_numeric"::BIGINT
        AND email."field" = 'email'
  LEFT JOIN "user_data" emailconfirmed
         ON emailconfirmed."uid" = uid."value_numeric"::BIGINT
        AND emailconfirmed."field" = 'email:confirmed'
  LEFT JOIN "user_data" password
         ON password."uid" = uid."value_numeric"::BIGINT
        AND password."field" = 'password'
  LEFT JOIN "user_data" passwordExpiry
         ON passwordExpiry."uid" = uid."value_numeric"::BIGINT
        AND passwordExpiry."field" = 'passwordExpiry'
  LEFT JOIN "user_data" joindate
         ON joindate."uid" = uid."value_numeric"::BIGINT
        AND joindate."field" = 'joindate'
  LEFT JOIN "user_data" lastonline
         ON lastonline."uid" = uid."value_numeric"::BIGINT
        AND lastonline."field" = 'lastonline'
  LEFT JOIN "user_data" lastposttime
         ON lastposttime."uid" = uid."value_numeric"::BIGINT
        AND lastposttime."field" = 'lastposttime'
  LEFT JOIN "user_data" lastqueuetime
         ON lastqueuetime."uid" = uid."value_numeric"::BIGINT
        AND lastqueuetime."field" = 'lastqueuetime'
  LEFT JOIN "user_data" rss_token
         ON rss_token."uid" = uid."value_numeric"::BIGINT
        AND rss_token."field" = 'rss_token'
  LEFT JOIN "user_data" acceptTos
         ON acceptTos."uid" = uid."value_numeric"::BIGINT
        AND acceptTos."field" = 'acceptTos'
  LEFT JOIN "user_data" gdpr_consent
         ON gdpr_consent."uid" = uid."value_numeric"::BIGINT
        AND gdpr_consent."field" = 'gdpr_consent'
  LEFT JOIN "user_data" reputation
         ON reputation."uid" = uid."value_numeric"::BIGINT
        AND reputation."field" = 'reputation'
  LEFT JOIN "user_data" banned
         ON banned."uid" = uid."value_numeric"::BIGINT
        AND banned."field" = 'banned'
  LEFT JOIN "user_data" bannedexpire
         ON bannedexpire."uid" = uid."value_numeric"::BIGINT
        AND bannedexpire."field" = 'banned:expire'
  LEFT JOIN "user_data" moderationNote
         ON moderationNote."uid" = uid."value_numeric"::BIGINT
        AND moderationNote."field" = 'moderationNote'
  LEFT JOIN "user_data" fullname
         ON fullname."uid" = uid."value_numeric"::BIGINT
        AND fullname."field" = 'fullname'
  LEFT JOIN "user_data" website
         ON website."uid" = uid."value_numeric"::BIGINT
        AND website."field" = 'website'
  LEFT JOIN "user_data" aboutme
         ON aboutme."uid" = uid."value_numeric"::BIGINT
        AND aboutme."field" = 'aboutme'
  LEFT JOIN "user_data" location
         ON location."uid" = uid."value_numeric"::BIGINT
        AND location."field" = 'location'
  LEFT JOIN "user_data" birthday
         ON birthday."uid" = uid."value_numeric"::BIGINT
        AND birthday."field" = 'birthday'
  LEFT JOIN "user_data" showemail
         ON showemail."uid" = uid."value_numeric"::BIGINT
        AND showemail."field" = 'showemail'
  LEFT JOIN "user_data" status
         ON status."uid" = uid."value_numeric"::BIGINT
        AND status."field" = 'status'
  LEFT JOIN "user_data" signature
         ON signature."uid" = uid."value_numeric"::BIGINT
        AND signature."field" = 'signature'
  LEFT JOIN "user_data" picture
         ON picture."uid" = uid."value_numeric"::BIGINT
        AND picture."field" = 'picture'
  LEFT JOIN "user_data" uploadedpicture
         ON uploadedpicture."uid" = uid."value_numeric"::BIGINT
        AND uploadedpicture."field" = 'uploadedpicture'
  LEFT JOIN "user_data" coverurl
         ON coverurl."uid" = uid."value_numeric"::BIGINT
        AND coverurl."field" = 'cover:url'
  LEFT JOIN "user_data" coverposition
         ON coverposition."uid" = uid."value_numeric"::BIGINT
        AND coverposition."field" = 'cover:position'
  LEFT JOIN "user_data" groupTitle
         ON groupTitle."uid" = uid."value_numeric"::BIGINT
        AND groupTitle."field" = 'groupTitle'
  LEFT JOIN "user_data" profileviews
         ON profileviews."uid" = uid."value_numeric"::BIGINT
        AND profileviews."field" = 'profileviews'
  LEFT JOIN "user_data" blocksCount
         ON blocksCount."uid" = uid."value_numeric"::BIGINT
        AND blocksCount."field" = 'blocksCount'
  LEFT JOIN "user_data" postcount
         ON postcount."uid" = uid."value_numeric"::BIGINT
        AND postcount."field" = 'postcount'
  LEFT JOIN "user_data" topiccount
         ON topiccount."uid" = uid."value_numeric"::BIGINT
        AND topiccount."field" = 'topiccount'
  LEFT JOIN "user_data" flags
         ON flags."uid" = uid."value_numeric"::BIGINT
        AND flags."field" = 'flags'
  LEFT JOIN "user_data" followerCount
         ON followerCount."uid" = uid."value_numeric"::BIGINT
        AND followerCount."field" = 'followerCount'
  LEFT JOIN "user_data" followingCount
         ON followingCount."uid" = uid."value_numeric"::BIGINT
        AND followingCount."field" = 'followingCount'
 WHERE uid."_key" = 'username:uid'
   AND uid."type" = 'zset';

\o /dev/null
SELECT setval('classify.users_uid_seq', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextUid')::BIGINT);
\o

ALTER TABLE "classify"."users"
	ADD PRIMARY KEY ("uid"),
	CLUSTER ON "users_pkey";
CREATE UNIQUE INDEX ON "classify"."users"("username");
CREATE UNIQUE INDEX ON "classify"."users"("userslug");
CREATE UNIQUE INDEX ON "classify"."users"("email");
CREATE INDEX ON "classify"."users"("joindate");
CREATE INDEX ON "classify"."users"("lastonline");
CREATE INDEX ON "classify"."users"("status", "lastonline");
CREATE INDEX ON "classify"."users"("reputation");
CREATE INDEX ON "classify"."users"("postcount");
