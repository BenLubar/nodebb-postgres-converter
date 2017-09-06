CREATE TABLE "posts" (
	"pid" bigserial NOT NULL,
	"uid" bigint,
	"tid" bigint NOT NULL,
	"toPid" bigint DEFAULT NULL,
	"ip" inet[] NOT NULL DEFAULT '{}',
	"timestamp" timestamptz NOT NULL DEFAULT NOW(),
	"content" text NOT NULL,
	"handle" text DEFAULT NULL,
	"bookmarks" bigint NOT NULL DEFAULT 0,
	"upvotes" bigint NOT NULL DEFAULT 0,
	"downvotes" bigint NOT NULL DEFAULT 0,
	"replies" bigint NOT NULL DEFAULT 0,
	"edited" timestamptz DEFAULT NULL,
	"editor" bigint DEFAULT NULL,
	"deleted" timestamptz DEFAULT NULL,
	"deleterUid" bigint DEFAULT NULL,
	"data" jsonb NOT NULL DEFAULT '{}'

	-- TODO:
	-- flag:assignee
	-- flag:history
	-- flag:notes
	-- flag:state
	-- flags
);

INSERT INTO "posts" SELECT
       (p."data"->>'pid')::bigint "pid",
       NULLIF(NULLIF(p."data"->>'uid', ''), '0')::bigint "uid",
       COALESCE(NULLIF(p."data"->>'tid', ''), '0')::bigint "tid",
       NULLIF(NULLIF(p."data"->>'toPid', ''), '0')::bigint "toPid",
       COALESCE(string_to_array(NULLIF(p."data"->>'ip', ''), ', ')::inet[], '{}') "ip",
       to_timestamp(NULLIF(NULLIF(p."data"->>'timestamp', ''), '0')::double precision / 1000) "timestamp",
       COALESCE(p."data"->>'content', '') "content",
       NULLIF(p."data"->>'handle', '') "handle",
       COALESCE(NULLIF(p."data"->>'bookmarks', ''), '0')::bigint "bookmarks",
       COALESCE(NULLIF(p."data"->>'upvotes', ''), '0')::bigint "upvotes",
       COALESCE(NULLIF(p."data"->>'downvotes', ''), '0')::bigint "downvotes",
       COALESCE(NULLIF(p."data"->>'replies', ''), '0')::bigint "replies",
       to_timestamp(NULLIF(NULLIF(p."data"->>'edited', ''), '0')::double precision / 1000) "edited",
       NULLIF(NULLIF(p."data"->>'editor', ''), '0')::bigint "editor",
       to_timestamp(NULLIF(NULLIF(p."data"->>'deleted', ''), '0')::double precision / 1000) "deleted",
       NULLIF(NULLIF(p."data"->>'deleterUid', ''), '0')::bigint "deleterUid",
       p."data" - 'pid' - 'tid' - 'uid' - 'toPid' - 'timestamp' - 'content' - 'handle' - 'bookmarks' - 'upvotes' - 'downvotes' - 'replies' - 'edited' - 'editor' - 'deleted' - 'deleterUid' "data"
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
