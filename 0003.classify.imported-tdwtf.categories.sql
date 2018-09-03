CREATE TABLE "classify"."imported_categories" (
	"cid" BIGINT NOT NULL,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

WITH telligent AS (
	SELECT "value_numeric"::BIGINT "discourse_id",
	       "unique_string"::BIGINT "telligent_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_telligent:_categories'
	   AND "type" = 'zset'
), discourse AS (
	SELECT "value_numeric"::BIGINT "cid",
	       "unique_string"::BIGINT "discourse_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_categories'
	   AND "type" = 'zset'
)
INSERT INTO "classify"."imported_categories"
SELECT discourse."cid",
       telligent."telligent_id",
       discourse."discourse_id"
  FROM discourse
  LEFT OUTER JOIN telligent
               ON discourse."discourse_id" = telligent."discourse_id";

ALTER TABLE "classify"."imported_categories"
	ADD PRIMARY KEY ("cid"),
	CLUSTER ON "imported_categories_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_categories" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_categories" ("discourse_id");
