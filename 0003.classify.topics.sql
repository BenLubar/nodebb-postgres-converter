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
	"search_language" REGCONFIG NOT NULL DEFAULT (SELECT "default_language" FROM "classify"."search_settings")
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
   FOR EACH ROW EXECUTE PROCEDURE TSVECTOR_UPDATE_TRIGGER_COLUMN("search_language", "search_language", "title");

WITH tids AS (
	SELECT u."unique_string"::BIGINT "tid",
	       'topic:' || u."unique_string" "key"
	  FROM "classify"."unclassified" u
	 WHERE u."_key" = 'topics:tid'
	   AND u."type" = 'zset'
)
INSERT INTO "classify"."topics"
SELECT tid,
       "classify"."get_hash_string"(key, 'cid')::BIGINT,
       NULLIF("classify"."get_hash_string"(key, 'oldCid'), '')::BIGINT,
       NULLIF(NULLIF("classify"."get_hash_string"(key, 'uid'), '0'), '')::BIGINT,
       "classify"."get_hash_string"(key, 'slug'),
       "classify"."get_hash_string"(key, 'title'),
       "classify"."get_hash_timestamp"(key, 'timestamp'),
       NULLIF("classify"."get_hash_string"(key, 'thumb'), ''),
       "classify"."get_hash_string"(key, 'mainPid')::BIGINT,
       "classify"."get_hash_string"(key, 'teaserPid')::BIGINT,
       "classify"."get_hash_string"(key, 'postcount')::BIGINT,
       "classify"."get_hash_timestamp"(key, 'lastposttime'),
       "classify"."get_hash_string"(key, 'upvotes')::BIGINT,
       "classify"."get_hash_string"(key, 'downvotes')::BIGINT,
       "classify"."get_hash_string"(key, 'viewcount')::BIGINT,
       COALESCE("classify"."get_hash_boolean"(key, 'locked'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'pinned'), FALSE),
       COALESCE("classify"."get_hash_boolean"(key, 'deleted'), FALSE),
       NULLIF(NULLIF("classify"."get_hash_string"(key, 'deleterUid'), '0'), '')::BIGINT,
       "classify"."get_hash_timestamp"(key, 'deletedTimestamp'),
       NULL,
       (SELECT "default_language" FROM "classify"."search_settings")
  FROM tids;

SELECT setval('classify.topics_tid_seq', "classify"."get_hash_string"('global', 'nextTid')::BIGINT);
