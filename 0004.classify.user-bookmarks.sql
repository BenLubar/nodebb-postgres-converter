CREATE TABLE "classify"."user_bookmarks" (
	"uid" BIGINT NOT NULL,
	"pid" BIGINT NOT NULL,
	"bookmarked_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."user_bookmarks"
SELECT SPLIT_PART("_key", ':', 2)::BIGINT,
       "unique_string"::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000)
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:bookmarks'
   AND "type" = 'zset';

ALTER TABLE "classify"."user_bookmarks"
	ADD PRIMARY KEY ("uid", "pid"),
	CLUSTER ON "user_bookmarks_pkey";
CREATE INDEX ON "classify"."user_bookmarks"("pid");
CREATE INDEX ON "classify"."user_bookmarks"("bookmarked_at");
