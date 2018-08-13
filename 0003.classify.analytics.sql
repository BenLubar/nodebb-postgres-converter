CREATE UNLOGGED TABLE "classify"."analytics_errors" (
	"http_status" INT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
)
PARTITION BY LIST ("http_status")
WITHOUT OIDS;

CREATE UNLOGGED TABLE "classify"."analytics_errors_404"
PARTITION OF "classify"."analytics_errors" (
	PRIMARY KEY ("hour")
)
FOR VALUES IN (404)
WITHOUT OIDS;

ALTER TABLE "classify"."analytics_errors_404" CLUSTER ON "analytics_errors_404_pkey";

CREATE UNLOGGED TABLE "classify"."analytics_errors_503"
PARTITION OF "classify"."analytics_errors" (
	PRIMARY KEY ("hour")
)
FOR VALUES IN (503)
WITHOUT OIDS;

ALTER TABLE "classify"."analytics_errors_503" CLUSTER ON "analytics_errors_503_pkey";

INSERT INTO "classify"."analytics_errors"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:errors:') + 1)::INT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:errors:%'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_flags" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_flags" CLUSTER ON "analytics_flags_pkey";

INSERT INTO "classify"."analytics_flags"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:flags'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_pageviews" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_pageviews" CLUSTER ON "analytics_pageviews_pkey";

INSERT INTO "classify"."analytics_pageviews"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:pageviews'
   AND "type" = 'zset';

CREATE VIEW "classify"."analytics_pageviews_month" AS
SELECT DATE_TRUNC('month', "hour") "month",
       SUM("count") "count"
  FROM "classify"."analytics_pageviews"
 GROUP BY DATE_TRUNC('month', "hour");

CREATE UNLOGGED TABLE "classify"."analytics_pageviews_byCid" (
	"cid" BIGINT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0,

	PRIMARY KEY ("cid", "hour")
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_pageviews_byCid" CLUSTER ON "analytics_pageviews_byCid_pkey";

INSERT INTO "classify"."analytics_pageviews_byCid"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:pageviews:byCid:') + 1)::BIGINT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:pageviews:byCid:%'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_posts" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_posts" CLUSTER ON "analytics_posts_pkey";

INSERT INTO "classify"."analytics_posts"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:posts'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_posts_byCid" (
	"cid" BIGINT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0,

	PRIMARY KEY ("cid", "hour")
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_posts_byCid" CLUSTER ON "analytics_posts_byCid_pkey";

INSERT INTO "classify"."analytics_posts_byCid"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:posts:byCid:') + 1)::BIGINT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:posts:byCid:%'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_topics" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_topics" CLUSTER ON "analytics_topics_pkey";

INSERT INTO "classify"."analytics_topics"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:topics'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_topics_byCid" (
	"cid" BIGINT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0,

	PRIMARY KEY ("cid", "hour")
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_topics_byCid" CLUSTER ON "analytics_topics_byCid_pkey";

INSERT INTO "classify"."analytics_topics_byCid"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:topics:byCid:') + 1)::BIGINT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:topics:byCid:%'
   AND "type" = 'zset';

CREATE UNLOGGED TABLE "classify"."analytics_uniquevisitors" (
	"hour" TIMESTAMPTZ NOT NULL PRIMARY KEY CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
) WITHOUT OIDS;

ALTER TABLE "classify"."analytics_uniquevisitors" CLUSTER ON "analytics_uniquevisitors_pkey";

INSERT INTO "classify"."analytics_uniquevisitors"
SELECT TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:uniquevisitors'
   AND "type" = 'zset';
