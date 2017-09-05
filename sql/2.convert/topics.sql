CREATE TABLE "topics" (
	"tid" bigserial NOT NULL,
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- cid
	-- deleted
	-- deletedTimestamp
	-- deleterUid
	-- lastposttime
	-- locked
	-- mainPid
	-- oldCid
	-- pinned
	-- postcount
	-- slug
	-- teaserPid
	-- thumb
	-- timestamp
	-- title
	-- uid
	-- viewcount
);

INSERT INTO "topics" SELECT
       (t."data"->>'tid')::bigint "tid",
       t."data" - 'tid' "data"
  FROM "objects_legacy" i,
       "objects_legacy" t
 WHERE i."key0" = 'topics'
   AND i."key1" = ARRAY['tid']
   AND t."key0" = 'topic'
   AND t."key1" = ARRAY[i."value"];

DO $$
DECLARE
	"nextTid" bigint;
BEGIN
	SELECT "data"->>'nextTid' INTO "nextTid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "topics_tid_seq" RESTART WITH ' || ("nextTid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "topics" ADD PRIMARY KEY ("tid");

CLUSTER "topics" USING "topics_pkey";

ANALYZE "topics";
