CREATE TYPE category_privilege AS ENUM ('find', 'read', 'topics:read', 'topics:create', 'topics:reply', 'topics:tag', 'posts:edit', 'posts:delete', 'topics:delete', 'upload:post:image', 'upload:post:file', 'purge', 'moderate');

CREATE TABLE "category_user_privileges" (
	"cid" bigint NOT NULL,
	"uid" bigint NOT NULL,
	"privilege" category_privilege NOT NULL,
	"granted_at" timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE "category_group_privileges" (
	"cid" bigint NOT NULL,
	"groupName" text NOT NULL,
	"privilege" category_privilege NOT NULL,
	"granted_at" timestamptz NOT NULL DEFAULT NOW()
);

INSERT INTO "category_user_privileges" SELECT
       i."value"::bigint "cid",
       p."value"::bigint "uid",
       e.e "privilege",
       to_timestamp(p."score"::double precision / 1000) "granted_at"
  FROM "objects_legacy" i
 CROSS JOIN UNNEST(enum_range(NULL::category_privilege)) e(e)
 INNER JOIN "objects_legacy" p
    ON p."key0" = 'group'
   AND p."key1" = ARRAY['cid', i."value", 'privileges'] || string_to_array(e.e::text, ':') || ARRAY['members']
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

INSERT INTO "category_group_privileges" SELECT
       i."value"::bigint "cid",
       p."value" "groupName",
       e.e "privilege",
       to_timestamp(p."score"::double precision / 1000) "granted_at"
  FROM "objects_legacy" i
 CROSS JOIN UNNEST(enum_range(NULL::category_privilege)) e(e)
 INNER JOIN "objects_legacy" p
    ON p."key0" = 'group'
   AND p."key1" = ARRAY['cid', i."value", 'privileges', 'groups'] || string_to_array(e.e::text, ':') || ARRAY['members']
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

ALTER TABLE "category_user_privileges" ADD PRIMARY KEY ("cid", "uid", "privilege");

ALTER TABLE "category_user_privileges"
      CLUSTER ON "category_user_privileges_pkey";

ALTER TABLE "category_group_privileges" ADD PRIMARY KEY ("cid", "groupName", "privilege");

ALTER TABLE "category_group_privileges"
      CLUSTER ON "category_group_privileges_pkey";
