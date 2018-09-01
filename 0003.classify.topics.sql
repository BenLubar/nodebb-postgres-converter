CREATE UNLOGGED TABLE "classify"."topics" (
	"tid" BIGSERIAL NOT NULL PRIMARY KEY,
	"cid" BIGINT NOT NULL,
	"oldCid" BIGINT,
	"uid" BIGINT,
	"slug" TEXT COLLATE "C" NOT NULL CHECK ("slug" LIKE "tid" || '/%'),
	"title" TEXT COLLATE "C" NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"thumb" TEXT COLLATE "C",

	"mainPid" BIGINT NOT NULL,
	"teaserPid" BIGINT NOT NULL,
	"postcount" BIGINT NOT NULL DEFAULT 1,
	"lastposttime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

	"upvotes" BIGINT NOT NULL DEFAULT 0,
	"downvotes" BIGINT NOT NULL DEFAULT 0,
	"viewcount" BIGINT NOT NULL DEFAULT 0,

	"locked" BOOLEAN NOT NULL DEFAULT FALSE,
	"pinned" BOOLEAN NOT NULL DEFAULT FALSE,
	"deleted" BOOLEAN NOT NULL DEFAULT FALSE,
	"deleterUid" BIGINT,
	"deletedTimestamp" TIMESTAMPTZ,

	"title_tsvector" TSVECTOR NOT NULL,
	"search_language" REGCONFIG NOT NULL DEFAULT "classify"."nodebb_default_search_language"()
) WITHOUT OIDS;

CREATE INDEX ON "classify"."topics"("cid", "pinned");
CREATE INDEX ON "classify"."topics"("uid");
CREATE INDEX ON "classify"."topics"("timestamp");
CREATE INDEX ON "classify"."topics"("lastposttime");
CREATE INDEX ON "classify"."topics"("deleted");
CREATE INDEX ON "classify"."topics"("viewcount");
CREATE INDEX ON "classify"."topics"(("upvotes" - "downvotes"));
CREATE INDEX ON "classify"."topics" USING GIN ("title_tsvector");

ALTER TABLE "classify"."topics" CLUSTER ON "topics_pkey";

CREATE TRIGGER "topics_search_update" BEFORE INSERT OR UPDATE OF "title", "search_language" ON "classify"."topics"
   FOR EACH ROW EXECUTE PROCEDURE TSVECTOR_UPDATE_TRIGGER_COLUMN("title_tsvector", "search_language", "title");

WITH tids AS (
	SELECT u."unique_string"::BIGINT "tid",
	       'topic:' || u."unique_string" "key"
	  FROM "classify"."unclassified" u
	 WHERE u."_key" = 'topics:tid'
	   AND u."type" = 'zset'
)
INSERT INTO "classify"."topics"
SELECT tid,
       "classify"."get_hash_int"(key, 'cid'),
       "classify"."get_hash_int"(key, 'oldCid'),
       "classify"."get_hash_int"(key, 'uid'),
       "classify"."get_hash_string"(key, 'slug'),
       "classify"."get_hash_string"(key, 'title'),
       "classify"."get_hash_timestamp"(key, 'timestamp'),
       "classify"."get_hash_string"(key, 'thumb'),
       "classify"."get_hash_int"(key, 'mainPid'),
       COALESCE("classify"."get_hash_int"(key, 'teaserPid'), "classify"."get_hash_int"(key, 'mainPid')),
       "classify"."get_hash_int"(key, 'postcount'),
       COALESCE("classify"."get_hash_timestamp"(key, 'lastposttime'), "classify"."get_hash_timestamp"(key, 'timestamp')),
       COALESCE("classify"."get_hash_int"(key, 'upvotes'), 0),
       COALESCE("classify"."get_hash_int"(key, 'downvotes'), 0),
       COALESCE("classify"."get_hash_int"(key, 'viewcount'), 0),
       COALESCE("classify"."get_hash_boolean"(key, 'locked'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'pinned'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'deleted'), FALSE),
       "classify"."get_hash_int"(key, 'deleterUid'),
       "classify"."get_hash_timestamp"(key, 'deletedTimestamp'),
       ''::TSVECTOR,
       "classify"."nodebb_default_search_language"()
  FROM tids
       -- somehow, some topics with no posts are in the WTDWTF database.
 WHERE "classify"."get_hash_int"(key, 'mainPid') IS NOT NULL;

SELECT setval('classify.topics_tid_seq', "classify"."get_hash_int"('global', 'nextTid'));
