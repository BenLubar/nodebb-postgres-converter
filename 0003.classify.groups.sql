CREATE TEMPORARY TABLE "group_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('group:') + 1) "name",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'group:%'
   AND "_key" NOT LIKE 'group:cid:%:%'
   AND "type" = 'hash';

ALTER TABLE "group_data"
	ADD PRIMARY KEY ("name", "field"),
	CLUSTER ON "group_data_pkey";

ANALYZE "group_data";

CREATE TABLE "classify"."groups" (
	"gid" BIGSERIAL NOT NULL,
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

	"userTitleEnabled" BOOLEAN NOT NULL DEFAULT FALSE CHECK (NOT "userTitleEnabled" OR "userTitle" IS NOT NULL),
	"userTitle" TEXT COLLATE "C",
	"labelColor" TEXT COLLATE "C",
	"icon" TEXT COLLATE "C",

	"cover:thumb:url" TEXT COLLATE "C",
	"cover:position" "classify".COVER_POSITION NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."groups"
SELECT NEXTVAL('classify.groups_gid_seq'::REGCLASS),
       name."unique_string",
       slug."value",
       TO_TIMESTAMP(createtime."value"::NUMERIC / 1000),
       COALESCE(description."value", ''),
       COALESCE(NULLIF(memberCount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(private."value", ''), '0') = '1',
       COALESCE(NULLIF(system."value", ''), '0') = '1',
       COALESCE(NULLIF(hidden."value", ''), '0') = '1',
       COALESCE(NULLIF(disableJoinRequests."value", ''), '0') = '1',
       COALESCE(NULLIF(deleted."value", ''), '0') = '1',
       COALESCE(NULLIF(userTitleEnabled."value", ''), '0') = '1',
       NULLIF(userTitle."value", ''),
       NULLIF(labelColor."value", ''),
       NULLIF(icon."value", ''),
       NULLIF(coverthumburl."value", ''),
       "classify"."parse_cover_position"(coverposition."value")
  FROM "classify"."unclassified" name
  LEFT JOIN "group_data" slug
         ON slug."name" = name."unique_string"
        AND slug."field" = 'slug'
  LEFT JOIN "group_data" createtime
         ON createtime."name" = name."unique_string"
        AND createtime."field" = 'createtime'
  LEFT JOIN "group_data" description
         ON description."name" = name."unique_string"
        AND description."field" = 'description'
  LEFT JOIN "group_data" memberCount
         ON memberCount."name" = name."unique_string"
        AND memberCount."field" = 'memberCount'
  LEFT JOIN "group_data" private
         ON private."name" = name."unique_string"
        AND private."field" = 'private'
  LEFT JOIN "group_data" system
         ON system."name" = name."unique_string"
        AND system."field" = 'system'
  LEFT JOIN "group_data" hidden
         ON hidden."name" = name."unique_string"
        AND hidden."field" = 'hidden'
  LEFT JOIN "group_data" disableJoinRequests
         ON disableJoinRequests."name" = name."unique_string"
        AND disableJoinRequests."field" = 'disableJoinRequests'
  LEFT JOIN "group_data" deleted
         ON deleted."name" = name."unique_string"
        AND deleted."field" = 'deleted'
  LEFT JOIN "group_data" userTitleEnabled
         ON userTitleEnabled."name" = name."unique_string"
        AND userTitleEnabled."field" = 'userTitleEnabled'
  LEFT JOIN "group_data" userTitle
         ON userTitle."name" = name."unique_string"
        AND userTitle."field" = 'userTitle'
  LEFT JOIN "group_data" labelColor
         ON labelColor."name" = name."unique_string"
        AND labelColor."field" = 'labelColor'
  LEFT JOIN "group_data" icon
         ON icon."name" = name."unique_string"
        AND icon."field" = 'icon'
  LEFT JOIN "group_data" coverthumburl
         ON coverthumburl."name" = name."unique_string"
        AND coverthumburl."field" = 'cover:thumb:url'
  LEFT JOIN "group_data" coverposition
         ON coverposition."name" = name."unique_string"
        AND coverposition."field" = 'cover:position'
 WHERE name."_key" = 'groups:createtime'
   AND name."type" = 'zset'
   AND name."unique_string" NOT LIKE 'cid:%:%';

ALTER TABLE "classify"."groups"
	ADD PRIMARY KEY ("gid"),
	CLUSTER ON "groups_pkey";
CREATE UNIQUE INDEX ON "classify"."groups"("name");
CREATE UNIQUE INDEX ON "classify"."groups"("slug");
CREATE INDEX ON "classify"."groups"("createtime");
CREATE INDEX ON "classify"."groups"("memberCount");
CREATE INDEX ON "classify"."groups"("hidden");

CREATE TYPE "classify".GROUP_MEMBER_TYPE AS ENUM (
	'member',
	'owner',
	'invited',
	'pending'
);

CREATE TABLE "classify"."group_members" (
	"gid" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"type" "classify".GROUP_MEMBER_TYPE NOT NULL,
	"joined_at" TIMESTAMPTZ CHECK ("joined_at" IS NOT NULL OR "type" NOT IN ('member', 'owner'))
) WITHOUT OIDS;

INSERT INTO "classify"."group_members"
SELECT g."gid",
       u."unique_string"::BIGINT,
       CASE WHEN o."unique_string" IS NULL THEN 'member' ELSE 'owner' END::"classify".GROUP_MEMBER_TYPE,
       TO_TIMESTAMP(u."value_numeric" / 1000)
  FROM "classify"."groups" g
 INNER JOIN "classify"."unclassified" u
         ON u."_key" = 'group:' || g."name" || ':members'
        AND u."type" = 'zset'
  LEFT JOIN "classify"."unclassified" o
         ON o."_key" = 'group:' || g."name" || ':owners'
        AND o."type" = 'set'
        AND o."unique_string" = u."unique_string";

INSERT INTO "classify"."group_members"
SELECT g."gid",
       u."unique_string"::BIGINT,
       t."type",
       NULL
  FROM "classify"."groups" g
 CROSS JOIN (
	VALUES ('invited'::"classify".GROUP_MEMBER_TYPE),
	       ('pending'::"classify".GROUP_MEMBER_TYPE)
            ) t("type")
 INNER JOIN "classify"."unclassified" u
         ON u."_key" = 'group:' || g."name" || ':' || t."type"
        AND u."type" = 'set'
  LEFT JOIN "classify"."group_members" gm
         ON gm."gid" = g."gid"
        AND gm."uid" = u."unique_string"::BIGINT
 WHERE gm."type" IS NULL;

ALTER TABLE "classify"."group_members"
	ADD PRIMARY KEY ("gid", "uid"),
	CLUSTER ON "group_members_pkey";
CREATE INDEX ON "classify"."group_members" ("type", "gid");
CREATE INDEX ON "classify"."group_members" ("uid");
