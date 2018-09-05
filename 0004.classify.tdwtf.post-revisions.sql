CREATE TYPE "classify".TDWTF_POST_REVISION_MODE AS ENUM (
	'edit'
);

CREATE TEMPORARY TABLE "post_revision_data" ON COMMIT DROP AS
SELECT SPLIT_PART("_key", ':', 2)::BIGINT "pid",
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000) "ts",
       REPLACE("value_string", '\u0000', '')::JSONB "data" -- PostgreSQL doesn't like null bytes in JSON.
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'pid:[0-9]+:postRevisions'
   AND "type" = 'hash'
   AND "unique_string" <> 'v';

ALTER TABLE "post_revision_data"
	ALTER "pid" SET NOT NULL,
	ALTER "ts" SET NOT NULL,
	ADD PRIMARY KEY ("pid", "ts"),
	CLUSTER ON "post_revision_data_pkey",
	ADD "uid" BIGINT,
	ADD "tid" BIGINT,
	ADD "cid" BIGINT,
	ADD "title" TEXT COLLATE "C",
	ADD "content" TEXT COLLATE "C",
	ADD "mode" "classify".TDWTF_POST_REVISION_MODE DEFAULT 'edit';

UPDATE "post_revision_data"
   SET "uid" = COALESCE("data"->>'uid', "data"->'post'->>'uid')::BIGINT,
       "tid" = ("data"->'post'->>'tid')::BIGINT,
       "cid" = ("data"->'topic'->>'cid')::BIGINT,
       "title" = "data"->'topic'->>'title',
       "content" = "data"->'post'->>'content',
       "mode" = ("data"->>'mode')::"classify".TDWTF_POST_REVISION_MODE;

ALTER TABLE "post_revision_data"
	ALTER "uid" SET NOT NULL,
	ALTER "tid" SET NOT NULL,
	ALTER "content" SET NOT NULL,
	ALTER "mode" SET NOT NULL,
	DROP "data";

INSERT INTO "post_revision_data" ("pid", "ts", "uid", "tid", "content")
SELECT SPLIT_PART("_key", ':', 2)::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       (REPLACE("unique_string", '\u0000', '')::JSONB->>'uid')::BIGINT,
       (REPLACE("unique_string", '\u0000', '')::JSONB->>'tid')::BIGINT,
       REPLACE("unique_string", '\u0000', '')::JSONB->>'content'
  FROM "classify"."unclassified"
  LEFT JOIN "post_revision_data"
         ON "pid" = SPLIT_PART("_key", ':', 2)::BIGINT
 WHERE "_key" SIMILAR TO 'pid:[0-9]+:revisions'
   AND "type" = 'zset'
   AND "pid" IS NULL;

UPDATE "post_revision_data" prd
   SET "cid" = COALESCE(prd."cid", (SELECT f."cid" FROM "post_revision_data" f WHERE f."cid" IS NOT NULL AND f."pid" = prd."pid" ORDER BY f."ts" ASC LIMIT 1), cid."value_string"::BIGINT),
       "title" = COALESCE(prd."title", (SELECT f."title" FROM "post_revision_data" f WHERE f."title" IS NOT NULL AND f."pid" = prd."pid" ORDER BY f."ts" ASC LIMIT 1), title."value_string")
  FROM "classify"."unclassified" cid,
       "classify"."unclassified" title
 WHERE cid."_key" = 'topic:' || prd."tid"
   AND cid."type" = 'hash'
   AND cid."unique_string" = 'cid'
   AND title."_key" = 'topic:' || prd."tid"
   AND title."type" = 'hash'
   AND title."unique_string" = 'title'
   AND (prd."cid" IS NULL OR prd."title" IS NULL);

ALTER TABLE "post_revision_data"
	ALTER "cid" SET NOT NULL,
	ALTER "title" SET NOT NULL;

ANALYZE "post_revision_data";

CREATE TABLE "classify"."tdwtf_post_revisions" (
	"revision_id" BIGSERIAL NOT NULL,
	"pid" BIGINT NOT NULL,
	"ts" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"tid" BIGINT NOT NULL,
	"cid" BIGINT NOT NULL,
	"topic_title" TEXT COLLATE "C" NOT NULL,
	"post_content" TEXT COLLATE "C" NOT NULL,
	"uid" BIGINT NOT NULL,
	"mode" "classify".TDWTF_POST_REVISION_MODE NOT NULL DEFAULT 'edit'
) WITHOUT OIDS;

INSERT INTO "classify"."tdwtf_post_revisions"
SELECT NEXTVAL('classify.tdwtf_post_revisions_revision_id_seq'::REGCLASS),
       "pid",
       "ts",
       "tid",
       "cid",
       "title",
       "content",
       "uid",
       "mode"
  FROM "post_revision_data"
 ORDER BY "ts" ASC;

CREATE UNIQUE INDEX ON "classify"."tdwtf_post_revisions"("pid", "ts");
ALTER TABLE "classify"."tdwtf_post_revisions"
	ADD PRIMARY KEY ("revision_id"),
	CLUSTER ON "tdwtf_post_revisions_pid_ts_idx";
