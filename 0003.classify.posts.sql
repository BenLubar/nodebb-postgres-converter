CREATE TABLE "classify"."posts" (
	-- main data
	"pid" BIGSERIAL PRIMARY KEY,
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

CREATE INDEX ON "classify"."posts"("timestamp");
CREATE INDEX ON "classify"."posts"("toPid");
CREATE INDEX ON "classify"."posts"("tid");
CREATE INDEX ON "classify"."posts"("uid");
CREATE INDEX ON "classify"."posts"("ip");
CREATE INDEX ON "classify"."posts"(("upvotes" - "downvotes"));
CREATE INDEX ON "classify"."posts" USING GIN ("content_tsvector");

ALTER TABLE "classify"."posts" CLUSTER ON "posts_pkey";

CREATE TRIGGER "posts_search_update" BEFORE INSERT OR UPDATE OF "content", "search_language" ON "classify"."posts"
   FOR EACH ROW EXECUTE PROCEDURE TSVECTOR_UPDATE_TRIGGER_COLUMN("content_tsvector", "search_language", "content");

WITH pids AS (
	SELECT "unique_string"::BIGINT "pid",
	       'post:' || "unique_string" "key"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'posts:pid'
	   AND "type" = 'zset'
)
INSERT INTO "classify"."posts"
SELECT pid,
       "classify"."get_hash_int"("key", 'toPid'),
       "classify"."get_hash_timestamp"("key", 'timestamp'),
       COALESCE("classify"."get_hash_string"("key", 'content'), ''),
       "classify"."get_hash_int"("key", 'tid'),
       "classify"."get_hash_int"("key", 'uid'),
       "classify"."get_hash_string"("key", 'handle'),
       SPLIT_PART("classify"."get_hash_string"("key", 'ip'), ',', 1)::INET,
       COALESCE("classify"."get_hash_int"("key", 'bookmarks'), 0),
       COALESCE("classify"."get_hash_int"("key", 'replies'), 0),
       COALESCE("classify"."get_hash_int"("key", 'upvotes'), 0),
       COALESCE("classify"."get_hash_int"("key", 'downvotes'), 0),
       COALESCE("classify"."get_hash_boolean"("key", 'deleted'), FALSE),
       "classify"."get_hash_int"("key", 'deleterUid'),
       "classify"."get_hash_timestamp"("key", 'edited'),
       "classify"."get_hash_int"("key", 'editor'),
       ''::TSVECTOR,
       "classify"."nodebb_default_search_language"()
  FROM pids;

\o /dev/null
SELECT setval('classify.posts_pid_seq', "classify"."get_hash_string"('global', 'nextPid')::BIGINT);
\o
