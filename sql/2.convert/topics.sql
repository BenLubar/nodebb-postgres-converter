CREATE TABLE "topics" (
	"tid" bigserial NOT NULL,
	"cid" bigint NOT NULL,
	"uid" bigint,
	"slug" text NOT NULL CHECK("slug" LIKE ("tid" || '/%')),
	"title" text NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW(),
	"mainPid" bigint,
	"teaserPid" bigint,
	"locked" boolean NOT NULL DEFAULT false,
	"deleted" boolean NOT NULL DEFAULT false,
	"deletedTimestamp" timestamptz DEFAULT NULL,
	"deleterUid" bigint DEFAULT NULL,
	"oldCid" bigint DEFAULT NULL,
	"viewcount" bigint NOT NULL DEFAULT 0,
	"postcount" bigint NOT NULL DEFAULT 0,
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- lastposttime
	-- pinned
	-- thumb
) WITH (autovacuum_enabled = false);

INSERT INTO "topics" SELECT
       (t."data"->>'tid')::bigint "tid",
       COALESCE(NULLIF(t."data"->>'cid', ''), '0')::bigint "cid",
       NULLIF(NULLIF(t."data"->>'uid', ''), '0')::bigint "uid",
       COALESCE(t."data"->>'slug', '') "slug",
       COALESCE(t."data"->>'title', '') "title",
       to_timestamp(NULLIF(NULLIF(t."data"->>'timestamp', ''), '0')::double precision / 1000) "timestamp",
       NULLIF(NULLIF(t."data"->>'mainPid', ''), '0')::bigint "mainPid",
       NULLIF(NULLIF(t."data"->>'teaserPid', ''), '0')::bigint "teaserPid",
       COALESCE(t."data"->>'locked', '0') = '1' "locked",
       COALESCE(t."data"->>'deleted', '0') = '1' "deleted",
       to_timestamp(NULLIF(NULLIF(t."data"->>'deletedTimestamp', ''), '0')::double precision / 1000) "deletedTimestamp",
       NULLIF(NULLIF(t."data"->>'deleterUid', ''), '0')::bigint "deleterUid",
       NULLIF(NULLIF(t."data"->>'oldCid', ''), '0')::bigint "oldCid",
       COALESCE(NULLIF(t."data"->>'viewcount', ''), '0')::bigint "viewcount",
       COALESCE(NULLIF(t."data"->>'postcount', ''), '0')::bigint "postcount",
       t."data" - 'tid' - 'cid' - 'uid' - 'slug' - 'title' - 'timestamp' - 'mainPid' - 'teaserPid' - 'locked' - 'deleted' - 'deletedTimestamp' - 'deleterUid' - 'oldCid' - 'viewcount' - 'postcount' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" t
    ON t."key0" = 'topic'
   AND t."key1" = ARRAY[i."value"]
 WHERE i."key0" = 'topics'
   AND i."key1" = ARRAY['tid'];

SELECT setval('"topics_tid_seq"', ("data"->>'nextTid')::bigint)
  FROM "objects_legacy"
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];

ALTER TABLE "topics" ADD PRIMARY KEY ("tid");

ALTER TABLE "topics"
      CLUSTER ON "topics_pkey";
