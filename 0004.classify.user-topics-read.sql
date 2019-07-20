CREATE TABLE "classify"."user_topics_read" (
	"uid" BIGINT NOT NULL,
	"tid" BIGINT NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"read" BOOLEAN NOT NULL DEFAULT FALSE
) WITHOUT OIDS;

INSERT INTO "classify"."user_topics_read"
SELECT SPLIT_PART("_key", ':', 2)::BIGINT,
       "unique_string"::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       true
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:tids_read'
   AND "type" = 'zset'
UNION ALL
SELECT SPLIT_PART("_key", ':', 2)::BIGINT,
       "unique_string"::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       false
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:tids_unread'
   AND "type" = 'zset';

ALTER TABLE "classify"."user_topics_read"
	ADD PRIMARY KEY ("tid", "uid"),
	CLUSTER ON "user_topics_read_pkey";
CREATE INDEX ON "classify"."user_topics_read"("uid", "read", "timestamp");
