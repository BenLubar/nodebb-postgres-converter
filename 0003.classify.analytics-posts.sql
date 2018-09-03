CREATE TABLE "classify"."analytics_posts" (
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

INSERT INTO "classify"."analytics_posts"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:posts'
   AND "type" = 'zset';

ALTER TABLE "classify"."analytics_posts"
	ADD PRIMARY KEY ("hour"),
	CLUSTER ON "analytics_posts_pkey";
