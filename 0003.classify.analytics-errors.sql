CREATE TABLE "classify"."analytics_errors" (
	"http_status" INT NOT NULL,
	"hour" TIMESTAMPTZ NOT NULL CHECK ("hour" = DATE_TRUNC('hour', "hour")),
	"count" BIGINT NOT NULL DEFAULT 0
)
PARTITION BY LIST ("http_status")
WITHOUT OIDS;

CREATE TABLE "classify"."analytics_errors_404"
PARTITION OF "classify"."analytics_errors"
FOR VALUES IN (404)
WITHOUT OIDS;

CREATE TABLE "classify"."analytics_errors_503"
PARTITION OF "classify"."analytics_errors"
FOR VALUES IN (503)
WITHOUT OIDS;

INSERT INTO "classify"."analytics_errors"
SELECT SUBSTRING("_key" FROM LENGTH('analytics:errors:') + 1)::INT,
       TO_TIMESTAMP("unique_string"::NUMERIC / 1000),
       "value_numeric"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'analytics:errors:%'
   AND "type" = 'zset';

ALTER TABLE "classify"."analytics_errors_404"
	ADD PRIMARY KEY ("hour"),
	CLUSTER ON "analytics_errors_404_pkey";

ALTER TABLE "classify"."analytics_errors_503"
	ADD PRIMARY KEY ("hour"),
	CLUSTER ON "analytics_errors_503_pkey";
