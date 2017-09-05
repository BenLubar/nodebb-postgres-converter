CREATE TABLE "posts" (
	"pid" bigserial NOT NULL,
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- bookmarks
	-- content
	-- deleted
	-- deleterUid
	-- downvotes
	-- edited
	-- editor
	-- flag:assignee
	-- flag:history
	-- flag:notes
	-- flag:state
	-- flags
	-- handle
	-- ip
	-- replies
	-- revisionCount
	-- tid
	-- timestamp
	-- toPid
	-- uid
	-- upvotes
);

INSERT INTO "posts" SELECT
       (p."data"->>'pid')::bigint "pid",
       p."data" - 'pid' "data"
  FROM "objects_legacy" i,
       "objects_legacy" p
 WHERE i."key0" = 'posts'
   AND i."key1" = ARRAY['pid']
   AND p."key0" = 'post'
   AND p."key1" = ARRAY[i."value"];

DO $$
DECLARE
	"nextPid" bigint;
BEGIN
	SELECT "data"->>'nextPid' INTO "nextPid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "posts_pid_seq" RESTART WITH ' || ("nextPid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "posts" ADD PRIMARY KEY ("pid");

CLUSTER "posts" USING "posts_pkey";

ANALYZE "posts";
