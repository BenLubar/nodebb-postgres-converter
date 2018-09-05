CREATE TABLE "classify"."user_read_positions" (
	"uid" BIGINT NOT NULL,
	"tid" BIGINT NOT NULL,
	"position" BIGINT NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."user_read_positions"
SELECT "unique_string"::BIGINT,
       SPLIT_PART("_key", ':', 2)::BIGINT,
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'tid:[0-9]+:bookmarks'
   AND "type" = 'zset';

ALTER TABLE "classify"."user_read_positions"
	ADD PRIMARY KEY ("uid", "tid"),
	CLUSTER ON "user_read_positions_pkey";
