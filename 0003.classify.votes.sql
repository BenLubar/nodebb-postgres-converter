CREATE TYPE "classify".POST_VOTE_TYPE AS ENUM (
	'upvote',
	'downvote'
);

CREATE TABLE "classify"."post_votes" (
	"pid" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"type" "classify".POST_VOTE_TYPE NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."post_votes"
SELECT v."unique_string"::BIGINT,
       SPLIT_PART(v."_key", ':', 2)::BIGINT,
       t."type",
       TO_TIMESTAMP(v."value_numeric" / 1000)
  FROM (VALUES ('upvote'::"classify".POST_VOTE_TYPE),
               ('downvote'::"classify".POST_VOTE_TYPE)) t("type")
 INNER JOIN "classify"."unclassified" v
         ON v."_key" SIMILAR TO 'uid:[0-9]+:' || t."type"
        AND v."type" = 'zset';

ALTER TABLE "classify"."post_votes"
	ADD PRIMARY KEY ("pid", "uid"),
	CLUSTER ON "post_votes_pkey";
CREATE INDEX ON "classify"."post_votes"("pid", "timestamp");
CREATE INDEX ON "classify"."post_votes"("uid", "timestamp");
CREATE INDEX ON "classify"."post_votes"("type");
