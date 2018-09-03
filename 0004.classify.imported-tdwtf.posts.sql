CREATE TABLE "classify"."imported_posts" (
	"pid" BIGINT NOT NULL,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT,

	CHECK ("telligent_id" IS NOT NULL OR "discourse_id" IS NOT NULL)
) WITHOUT OIDS;

WITH telligent AS (
	SELECT "value_numeric"::BIGINT "pid",
	       "unique_string"::BIGINT / 2 "telligent_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_posts'
	   AND "type" = 'zset'
	   AND "unique_string"::BIGINT & 1 = 0
), discourse AS (
	SELECT "value_numeric"::BIGINT "pid",
	       ("unique_string"::BIGINT - 1) / 2 "discourse_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_posts'
	   AND "type" = 'zset'
	   AND "unique_string"::BIGINT & 1 = 1
)
INSERT INTO "classify"."imported_posts"
SELECT COALESCE(telligent."pid", discourse."pid"),
       telligent."telligent_id",
       discourse."discourse_id"
  FROM telligent
  FULL OUTER JOIN discourse
               ON telligent."pid" = discourse."pid";

ALTER TABLE "classify"."imported_posts"
	ADD PRIMARY KEY ("pid"),
	CLUSTER ON "imported_posts_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_posts" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_posts" ("discourse_id");
