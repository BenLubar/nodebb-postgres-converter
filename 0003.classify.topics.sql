CREATE TEMPORARY TABLE "topic_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('topic:') + 1)::BIGINT "tid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'topic:[0-9]+'
   AND "type" = 'hash';

ALTER TABLE "topic_data"
	ADD PRIMARY KEY ("tid", "field"),
	CLUSTER ON "topic_data_pkey";

ANALYZE "topic_data";

CREATE TABLE "classify"."topics" (
	"tid" BIGSERIAL NOT NULL,
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

INSERT INTO "classify"."topics"
SELECT tid."unique_string"::BIGINT,
       cid."value"::BIGINT,
       NULLIF(NULLIF(oldCid."value", ''), '0')::BIGINT,
       NULLIF(NULLIF(uid."value", ''), '0')::BIGINT,
       slug."value",
       title."value",
       TO_TIMESTAMP(timestamp."value"::NUMERIC / 1000),
       NULLIF(thumb."value", ''),
       mainPid."value"::BIGINT,
       COALESCE(NULLIF(NULLIF(teaserPid."value", ''), '0'), mainPid."value")::BIGINT,
       COALESCE(NULLIF(postcount."value", ''), '0')::BIGINT,
       TO_TIMESTAMP(COALESCE(NULLIF(NULLIF(lastposttime."value", ''), '0'), timestamp."value")::NUMERIC / 1000),
       COALESCE(NULLIF(upvotes."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(downvotes."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(viewcount."value", ''), '0')::BIGINT,
       COALESCE(NULLIF(locked."value", ''), '0') = '1',
       COALESCE(NULLIF(pinned."value", ''), '0') = '1',
       COALESCE(NULLIF(deleted."value", ''), '0') = '1',
       NULLIF(NULLIF(deleterUid."value", ''), '0')::BIGINT,
       TO_TIMESTAMP(NULLIF(NULLIF(deletedTimestamp."value", ''), '0')::NUMERIC / 1000),
       TO_TSVECTOR("classify"."nodebb_default_search_language"(), title."value"),
       "classify"."nodebb_default_search_language"()
  FROM "classify"."unclassified" tid
  LEFT JOIN "topic_data" cid
         ON cid."tid" = tid."unique_string"::BIGINT
        AND cid."field" = 'cid'
  LEFT JOIN "topic_data" oldCid
         ON oldCid."tid" = tid."unique_string"::BIGINT
        AND oldCid."field" = 'oldCid'
  LEFT JOIN "topic_data" uid
         ON uid."tid" = tid."unique_string"::BIGINT
        AND uid."field" = 'uid'
  LEFT JOIN "topic_data" slug
         ON slug."tid" = tid."unique_string"::BIGINT
        AND slug."field" = 'slug'
  LEFT JOIN "topic_data" title
         ON title."tid" = tid."unique_string"::BIGINT
        AND title."field" = 'title'
  LEFT JOIN "topic_data" timestamp
         ON timestamp."tid" = tid."unique_string"::BIGINT
        AND timestamp."field" = 'timestamp'
  LEFT JOIN "topic_data" thumb
         ON thumb."tid" = tid."unique_string"::BIGINT
        AND thumb."field" = 'thumb'
  LEFT JOIN "topic_data" mainPid
         ON mainPid."tid" = tid."unique_string"::BIGINT
        AND mainPid."field" = 'mainPid'
  LEFT JOIN "topic_data" teaserPid
         ON teaserPid."tid" = tid."unique_string"::BIGINT
        AND teaserPid."field" = 'teaserPid'
  LEFT JOIN "topic_data" postcount
         ON postcount."tid" = tid."unique_string"::BIGINT
        AND postcount."field" = 'postcount'
  LEFT JOIN "topic_data" lastposttime
         ON lastposttime."tid" = tid."unique_string"::BIGINT
        AND lastposttime."field" = 'lastposttime'
  LEFT JOIN "topic_data" upvotes
         ON upvotes."tid" = tid."unique_string"::BIGINT
        AND upvotes."field" = 'upvotes'
  LEFT JOIN "topic_data" downvotes
         ON downvotes."tid" = tid."unique_string"::BIGINT
        AND downvotes."field" = 'downvotes'
  LEFT JOIN "topic_data" viewcount
         ON viewcount."tid" = tid."unique_string"::BIGINT
        AND viewcount."field" = 'viewcount'
  LEFT JOIN "topic_data" locked
         ON locked."tid" = tid."unique_string"::BIGINT
        AND locked."field" = 'locked'
  LEFT JOIN "topic_data" pinned
         ON pinned."tid" = tid."unique_string"::BIGINT
        AND pinned."field" = 'pinned'
  LEFT JOIN "topic_data" deleted
         ON deleted."tid" = tid."unique_string"::BIGINT
        AND deleted."field" = 'deleted'
  LEFT JOIN "topic_data" deleterUid
         ON deleterUid."tid" = tid."unique_string"::BIGINT
        AND deleterUid."field" = 'deleterUid'
  LEFT JOIN "topic_data" deletedTimestamp
         ON deletedTimestamp."tid" = tid."unique_string"::BIGINT
        AND deletedTimestamp."field" = 'deletedTimestamp'
 WHERE tid."_key" = 'topics:tid'
   AND tid."type" = 'zset'
   AND -- somehow, some topics with no posts are in the WTDWTF database.
       COALESCE(NULLIF(mainPid."value", ''), '0')::BIGINT <> 0;

CREATE TRIGGER "topics_search_update" BEFORE INSERT OR UPDATE OF "title", "search_language" ON "classify"."topics"
   FOR EACH ROW EXECUTE PROCEDURE TSVECTOR_UPDATE_TRIGGER_COLUMN("title_tsvector", "search_language", "title");

\o /dev/null
SELECT setval('classify.topics_tid_seq', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextTid')::BIGINT);
\o

ALTER TABLE "classify"."topics"
	ADD PRIMARY KEY ("tid"),
	CLUSTER ON "topics_pkey";
CREATE INDEX ON "classify"."topics"("cid", "pinned");
CREATE INDEX ON "classify"."topics"("uid");
CREATE INDEX ON "classify"."topics"("timestamp");
CREATE INDEX ON "classify"."topics"("lastposttime");
CREATE INDEX ON "classify"."topics"("deleted");
CREATE INDEX ON "classify"."topics"("viewcount");
CREATE INDEX ON "classify"."topics"(("upvotes" - "downvotes"));
CREATE INDEX ON "classify"."topics" USING GIN ("title_tsvector");
