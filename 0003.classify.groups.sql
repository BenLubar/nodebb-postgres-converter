CREATE UNLOGGED TABLE "classify"."groups" (
	"gid" BIGSERIAL NOT NULL PRIMARY KEY,
	"name" TEXT COLLATE "C" NOT NULL,
	"slug" TEXT COLLATE "C" NOT NULL,
	"createtime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"description" TEXT COLLATE "C" NOT NULL DEFAULT '',
	"memberCount" BIGINT NOT NULL DEFAULT 0,

	"private" BOOLEAN NOT NULL DEFAULT FALSE,
	"system" BOOLEAN NOT NULL DEFAULT FALSE,
	"hidden" BOOLEAN NOT NULL DEFAULT FALSE,
	"disableJoinRequests" BOOLEAN NOT NULL DEFAULT FALSE,
	"deleted" BOOLEAN NOT NULL DEFAULT FALSE,

	"userTitleEnabled" BOOLEAN NOT NULL DEFAULT FALSE CHECK(NOT "userTitleEnabled" OR "userTitle" IS NOT NULL),
	"userTitle" TEXT COLLATE "C",
	"labelColor" TEXT COLLATE "C",
	"icon" TEXT COLLATE "C",

	"cover:thumb:url" TEXT COLLATE "C",
	"cover:position" TEXT COLLATE "C"
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."groups"("name");
CREATE UNIQUE INDEX ON "classify"."groups"("slug");
CREATE INDEX ON "classify"."groups"("createtime");
CREATE INDEX ON "classify"."groups"("memberCount");
CREATE INDEX ON "classify"."groups"("hidden");

ALTER TABLE "classify"."groups" CLUSTER ON "groups_pkey";

WITH gids AS (
	SELECT u."unique_string" "name",
	       'group:' || u."unique_string" "key",
	       NEXTVAL('classify.groups_gid_seq'::REGCLASS) "gid"
	  FROM "classify"."unclassified" u
	 WHERE u."_key" = 'groups:createtime'
	   AND u."type" = 'zset'
	   AND u."unique_string" NOT LIKE 'cid:%:%'
	 ORDER BY u."value_numeric" ASC
)
INSERT INTO "classify"."groups"
SELECT gid,
       "classify"."get_hash_string"(key, 'name'),
       "classify"."get_hash_string"(key, 'slug'),
       "classify"."get_hash_timestamp"(key, 'createtime'),
       COALESCE("classify"."get_hash_string"(key, 'description'), ''),
       COALESCE("classify"."get_hash_string"(key, 'memberCount')::BIGINT, 0),

       COALESCE("classify"."get_hash_boolean"(key, 'private'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'system'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'hidden'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'disableJoinRequests'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'deleted'), FALSE),

       COALESCE("classify"."get_hash_boolean"(key, 'userTitleEnabled'), FALSE),
       "classify"."get_hash_string"(key, 'userTitle'),
       "classify"."get_hash_string"(key, 'labelColor'),
       "classify"."get_hash_string"(key, 'icon'),

       "classify"."get_hash_string"(key, 'cover:thumb:url'),
       "classify"."get_hash_string"(key, 'cover:position')
  FROM gids;

CREATE TYPE "classify".GROUP_MEMBER_TYPE AS ENUM (
	'member',
	'owner',
	'invited',
	'pending'
);

CREATE UNLOGGED TABLE "classify"."group_members" (
	"gid" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"type" GROUP_MEMBER_TYPE NOT NULL,
	"joined_at" TIMESTAMPTZ CHECK("joined_at" IS NOT NULL OR "type" NOT IN ('member', 'owner')),

	PRIMARY KEY ("gid", "uid")
) WITHOUT OIDS;

CREATE INDEX ON "classify"."group_members" ("type", "gid");
CREATE INDEX ON "classify"."group_members" ("uid");

ALTER TABLE "classify"."group_members" CLUSTER ON "group_members_pkey";

INSERT INTO "classify"."group_members"
SELECT g."gid",
       u."unique_string"::BIGINT,
       CASE WHEN o."unique_string" IS NULL THEN 'member' ELSE 'owner' END,
       TO_TIMESTAMP(u."value_numeric" / 1000)
  FROM "classify"."groups" g
 INNER JOIN "classify"."unclassified" u
         ON u."_key" = 'group:' || g."name" || ':members'
        AND u."type" = 'zset'
  LEFT JOIN "classify"."unclassified" o
         ON o."_key" = 'group:' || g."name" || ':owners'
        AND o."type" = 'set'
        AND o."unique_string" = u."unique_string"
UNION ALL
SELECT g."gid",
       u."unique_string"::BIGINT,
       'invited',
       NULL
  FROM "classify"."groups" g
 INNER JOIN "classify"."unclassified" u
         ON u."_key" = 'group:' || g."name" || ':invited'
        AND u."type" = 'set'
UNION ALL
SELECT g."gid",
       u."unique_string"::BIGINT,
       'pending',
       NULL
  FROM "classify"."groups" g
 INNER JOIN "classify"."unclassified" u
         ON u."_key" = 'group:' || g."name" || ':pending'
        AND u."type" = 'set';
