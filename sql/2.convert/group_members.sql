CREATE TYPE group_membership AS ENUM ('member', 'owner', 'pending', 'invited');

CREATE TABLE "group_members" (
	"groupName" text NOT NULL,
	"uid" bigint NOT NULL,
	"type" group_membership NOT NULL,
	"joined" timestamptz DEFAULT NULL,

	CHECK (("type" IN ('member', 'owner')) = ("joined" IS NOT NULL))
) WITH (autovacuum_enabled = false);

INSERT INTO "group_members" SELECT
       i."value" "groupName",
       g."value"::bigint "uid",
       CASE WHEN EXISTS(SELECT 1
                          FROM "objects_legacy" o
                         WHERE o."key0" = 'group'
                           AND o."key1" = ARRAY[i."value", 'owners']
                           AND (o."data"->'members') ? g."value")
       THEN 'owner'::group_membership
       ELSE 'member'::group_membership
       END "type",
       to_timestamp(g."score"::double precision / 1000) "joined"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" g
    ON g."key0" = 'group'
   AND g."key1" = ARRAY[i."value", 'members']
 WHERE i."key0" = 'groups'
   AND i."key1" = ARRAY['createtime']
 UNION ALL
SELECT i."value" "groupName",
       u."id"::bigint "uid",
       'pending'::group_membership "type",
       NULL "joined"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" g
    ON g."key0" = 'group'
   AND g."key1" = ARRAY[i."value", 'pending']
 CROSS JOIN jsonb_array_elements_text(g."data"->'members') u("id")
  LEFT OUTER JOIN "objects_legacy" m
    ON m."key0" = 'group'
   AND m."key1" = ARRAY[i."value", 'members']
   AND m."value" = u."id"
 WHERE i."key0" = 'groups'
   AND i."key1" = ARRAY['createtime']
   AND m."value" IS NULL
 UNION ALL
SELECT i."value" "groupName",
       u."id"::bigint "uid",
       'invited'::group_membership "type",
       NULL "joined"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" g
    ON g."key0" = 'group'
   AND g."key1" = ARRAY[i."value", 'invited']
 CROSS JOIN jsonb_array_elements_text(g."data"->'members') u("id")
  LEFT OUTER JOIN "objects_legacy" m
    ON m."key0" = 'group'
   AND m."key1" = ARRAY[i."value", 'members']
   AND m."value" = u."id"
 WHERE i."key0" = 'groups'
   AND i."key1" = ARRAY['createtime']
   AND m."value" IS NULL;

ALTER TABLE "group_members" ADD PRIMARY KEY ("groupName", "uid");

CREATE INDEX "idx__group_members__groupName__type" ON "group_members"("groupName", "type");

ALTER TABLE "group_members"
      CLUSTER ON "group_members_pkey";
