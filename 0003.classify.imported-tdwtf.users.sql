CREATE TABLE "classify"."imported_users" (
	"uid" BIGINT NOT NULL,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

WITH telligent AS (
	SELECT "value_numeric"::BIGINT "discourse_id",
	       "unique_string"::BIGINT "telligent_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_telligent:_users'
	   AND "type" = 'zset'
), discourse AS (
	SELECT "value_numeric"::BIGINT "uid",
	       "unique_string"::BIGINT "discourse_id"
	  FROM "classify"."unclassified"
	 WHERE "_key" = '_imported:_users'
	   AND "type" = 'zset'
)
INSERT INTO "classify"."imported_users"
SELECT discourse."uid",
       telligent."telligent_id",
       discourse."discourse_id"
  FROM discourse
  LEFT OUTER JOIN telligent
               ON discourse."discourse_id" = telligent."discourse_id";

ALTER TABLE "classify"."imported_users"
	ADD PRIMARY KEY ("uid"),
	CLUSTER ON "imported_users_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_users" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_users" ("discourse_id");
