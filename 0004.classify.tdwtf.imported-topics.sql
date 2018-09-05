CREATE TABLE "classify"."imported_topics" (
	"tid" BIGINT NOT NULL,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT,

	CHECK ("telligent_id" IS NOT NULL OR "discourse_id" IS NOT NULL)
) WITHOUT OIDS;

WITH telligent AS (
	SELECT "value_numeric"::BIGINT "tid",
	       "unique_string"::BIGINT / 2 "telligent_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_topics'
	   AND "type" = 'zset'
	   AND "unique_string"::BIGINT & 1 = 0
), discourse AS (
	SELECT "value_numeric"::BIGINT "tid",
	       ("unique_string"::BIGINT - 1) / 2 "discourse_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_topics'
	   AND "type" = 'zset'
	   AND "unique_string"::BIGINT & 1 = 1
)
INSERT INTO "classify"."imported_topics"
SELECT COALESCE(telligent."tid", discourse."tid"),
       telligent."telligent_id",
       discourse."discourse_id"
  FROM telligent
  FULL OUTER JOIN discourse
               ON telligent."tid" = discourse."tid";

ALTER TABLE "classify"."imported_topics"
	ADD PRIMARY KEY ("tid"),
	CLUSTER ON "imported_topics_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_topics" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_topics" ("discourse_id");
