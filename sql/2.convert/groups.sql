CREATE TABLE "groups" (
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"createtime" timestamptz NOT NULL DEFAULT NOW(),
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO
	-- cover:position
	-- cover:thumb:url
	-- cover:url
	-- deleted
	-- description
	-- disableJoinRequests
	-- hidden
	-- icon
	-- labelColor
	-- memberCount
	-- ownerUid
	-- private
	-- system
	-- userTitle
	-- userTitleEnabled
);

INSERT INTO "groups" SELECT
       g."data"->>'name' "name",
       g."data"->>'slug' "slug",
       to_timestamp(COALESCE(g."data"->>'createtime', '0')::double precision / 1000) "createtime",
       g."data" - 'name' - 'slug' - 'createtime' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" g
    ON g."key0" = 'group'
   AND g."key1" = ARRAY[i."value"]
 WHERE i."key0" = 'groups'
   AND i."key1" = ARRAY['createtime'];

ALTER TABLE "groups" ADD PRIMARY KEY ("name");

CLUSTER "groups" USING "groups_pkey";

CREATE UNIQUE INDEX "uniq__groups__slug" ON "groups"("slug");

ANALYZE "groups";
