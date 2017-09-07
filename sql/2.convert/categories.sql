CREATE TABLE "categories" (
	"cid" bigserial NOT NULL,
	"parentCid" bigint DEFAULT NULL,
	"name" text NOT NULL,
	"slug" text NOT NULL CHECK("slug" LIKE ("cid" || '/%')),
	"disabled" boolean NOT NULL DEFAULT false,
	"order" int NOT NULL,
	"description" text NOT NULL DEFAULT '',
	"descriptionParsed" text DEFAULT NULL,
	"post_count" bigint NOT NULL DEFAULT 0,
	"topic_count" bigint NOT NULL DEFAULT 0,
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- color
	-- bgColor
	-- class
	-- icon
	-- image
	-- imageClass
	-- link
	-- numRecentReplies
	-- timesClicked
);

INSERT INTO "categories" SELECT
       (c."data"->>'cid')::bigint "cid",
       NULLIF(NULLIF(c."data"->>'parentCid', ''), '0')::bigint "parentCid",
       c."data"->>'name' "name",
       c."data"->>'slug' "slug",
       COALESCE(c."data"->>'disabled', '0') = '1' "disabled",
       NULLIF(c."data"->>'order', '')::int "order",
       c."data"->>'description' "description",
       CASE WHEN c."data" ? 'descriptionParsed' THEN c."data"->>'descriptionParsed' ELSE NULL END "descriptionParsed",
       COALESCE(NULLIF(c."data"->>'post_count', ''), '0')::bigint "post_count",
       COALESCE(NULLIF(c."data"->>'topic_count', ''), '0')::bigint "topic_count",
       c."data" - 'cid' - 'parentCid' - 'name' - 'slug' - 'disabled' - 'order' - 'description' - 'descriptionParsed' - 'post_count' - 'topic_count' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" c
    ON c."key0" = 'category'
   AND c."key1" = ARRAY[i."value"]
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid'];

DO $$
DECLARE
	"nextCid" bigint;
BEGIN
	SELECT "data"->>'nextCid' INTO "nextCid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "categories_cid_seq" RESTART WITH ' || ("nextCid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "categories" ADD PRIMARY KEY ("cid");

CREATE UNIQUE INDEX "uniq__categories__slug"
    ON "categories"("slug");

CREATE INDEX "idx__categories__parentCid__order"
    ON "categories"("parentCid", "order");

CLUSTER "categories" USING "categories_pkey";

ANALYZE "categories";
