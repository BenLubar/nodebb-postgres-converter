CREATE TEMPORARY TABLE "post_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('post:') + 1)::BIGINT "pid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'post:[0-9]+'
   AND "type" = 'hash';

ALTER TABLE "post_data"
	ADD PRIMARY KEY ("pid", "field"),
	CLUSTER ON "post_data_pkey";

ANALYZE "post_data";

CREATE TABLE "classify"."posts" (
	-- main data
	"pid" BIGSERIAL,
	"toPid" BIGINT,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"content" TEXT COLLATE "C" NOT NULL,
	"tid" BIGINT NOT NULL,
	"uid" BIGINT,
	"handle" TEXT COLLATE "C",
	"ip" INET,

	-- counters
	"bookmarks" BIGINT NOT NULL DEFAULT 0,
	"replies" BIGINT NOT NULL DEFAULT 0,
	"upvotes" BIGINT NOT NULL DEFAULT 0,
	"downvotes" BIGINT NOT NULL DEFAULT 0,

	-- modifications
	"deleted" BOOLEAN NOT NULL DEFAULT FALSE,
	"deleterUid" BIGINT,
	"edited" TIMESTAMPTZ,
	"editor" BIGINT,

	"content_tsvector" TSVECTOR NOT NULL,
	"search_language" REGCONFIG NOT NULL DEFAULT "classify"."nodebb_default_search_language"()
) WITHOUT OIDS;

INSERT INTO "classify"."posts"
SELECT pid."unique_string"::BIGINT,
       NULLIF(NULLIF(toPid."value", ''), '0')::BIGINT,
       TO_TIMESTAMP(timestamp."value"::NUMERIC / 1000),
       COALESCE(content."value", ''),
       tid."value"::BIGINT,
       NULLIF(NULLIF(uid."value", ''), '0')::BIGINT,
       NULLIF(handle."value", ''),
       SPLIT_PART(NULLIF(ip."value", ''), ',', 1)::INET,
       COALESCE(NULLIF(bookmarks."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(replies."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(upvotes."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(downvotes."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(deleted."value", ''), '0') = '1',
       NULLIF(NULLIF(deleterUid."value", ''), '0')::BIGINT,
       TO_TIMESTAMP(NULLIF(NULLIF(edited."value", ''), '0')::NUMERIC / 1000),
       NULLIF(NULLIF(editor."value", ''), '0')::BIGINT,
       TO_TSVECTOR("classify"."nodebb_default_search_language"(), COALESCE(content."value", '')),
       "classify"."nodebb_default_search_language"()
  FROM "classify"."unclassified" pid
  LEFT JOIN "post_data" toPid
         ON toPid."pid" = pid."unique_string"::BIGINT
        AND toPid."field" = 'toPid'
  LEFT JOIN "post_data" timestamp
         ON timestamp."pid" = pid."unique_string"::BIGINT
        AND timestamp."field" = 'timestamp'
  LEFT JOIN "post_data" content
         ON content."pid" = pid."unique_string"::BIGINT
        AND content."field" = 'content'
  LEFT JOIN "post_data" tid
         ON tid."pid" = pid."unique_string"::BIGINT
        AND tid."field" = 'tid'
  LEFT JOIN "post_data" uid
         ON uid."pid" = pid."unique_string"::BIGINT
        AND uid."field" = 'uid'
  LEFT JOIN "post_data" handle
         ON handle."pid" = pid."unique_string"::BIGINT
        AND handle."field" = 'handle'
  LEFT JOIN "post_data" ip
         ON ip."pid" = pid."unique_string"::BIGINT
        AND ip."field" = 'ip'
  LEFT JOIN "post_data" bookmarks
         ON bookmarks."pid" = pid."unique_string"::BIGINT
        AND bookmarks."field" = 'bookmarks'
  LEFT JOIN "post_data" replies
         ON replies."pid" = pid."unique_string"::BIGINT
        AND replies."field" = 'replies'
  LEFT JOIN "post_data" upvotes
         ON upvotes."pid" = pid."unique_string"::BIGINT
        AND upvotes."field" = 'upvotes'
  LEFT JOIN "post_data" downvotes
         ON downvotes."pid" = pid."unique_string"::BIGINT
        AND downvotes."field" = 'downvotes'
  LEFT JOIN "post_data" deleted
         ON deleted."pid" = pid."unique_string"::BIGINT
        AND deleted."field" = 'deleted'
  LEFT JOIN "post_data" deleterUid
         ON deleterUid."pid" = pid."unique_string"::BIGINT
        AND deleterUid."field" = 'deleterUid'
  LEFT JOIN "post_data" edited
         ON edited."pid" = pid."unique_string"::BIGINT
        AND edited."field" = 'edited'
  LEFT JOIN "post_data" editor
         ON editor."pid" = pid."unique_string"::BIGINT
        AND editor."field" = 'editor'
 WHERE pid."_key" = 'posts:pid'
   AND pid."type" = 'zset';

CREATE TRIGGER "posts_search_update" BEFORE INSERT OR UPDATE OF "content", "search_language" ON "classify"."posts"
   FOR EACH ROW EXECUTE PROCEDURE TSVECTOR_UPDATE_TRIGGER_COLUMN("content_tsvector", "search_language", "content");

\o /dev/null
SELECT setval('classify.posts_pid_seq', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextPid')::BIGINT);
\o

ALTER TABLE "classify"."posts"
	ADD PRIMARY KEY("pid"),
	CLUSTER ON "posts_pkey";
CREATE INDEX ON "classify"."posts"("timestamp");
CREATE INDEX ON "classify"."posts"("toPid");
CREATE INDEX ON "classify"."posts"("tid");
CREATE INDEX ON "classify"."posts"("uid");
CREATE INDEX ON "classify"."posts"("ip");
CREATE INDEX ON "classify"."posts"(("upvotes" - "downvotes"));
CREATE INDEX ON "classify"."posts" USING GIN ("content_tsvector");
