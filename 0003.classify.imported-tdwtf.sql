CREATE TABLE "classify"."imported_categories" (
	"cid" BIGINT NOT NULL PRIMARY KEY,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_categories" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_categories" ("discourse_id");

ALTER TABLE "classify"."imported_categories" CLUSTER ON "imported_categories_pkey";

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

CREATE TABLE "classify"."imported_messages" (
	"mid" BIGINT NOT NULL PRIMARY KEY,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_messages" ("discourse_id");

ALTER TABLE "classify"."imported_messages" CLUSTER ON "imported_messages_pkey";

INSERT INTO "classify"."imported_messages"
SELECT "value_numeric"::BIGINT,
       "unique_string"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = '_imported:_messages'
   AND "type" = 'zset';

CREATE TABLE "classify"."imported_posts" (
	"pid" BIGINT NOT NULL PRIMARY KEY,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT,

	CHECK ("telligent_id" IS NOT NULL OR "discourse_id" IS NOT NULL)
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_posts" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_posts" ("discourse_id");

ALTER TABLE "classify"."imported_posts" CLUSTER ON "imported_posts_pkey";

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

CREATE TABLE "classify"."imported_rooms" (
	"roomId" BIGINT NOT NULL PRIMARY KEY,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_rooms" ("discourse_id");

ALTER TABLE "classify"."imported_rooms" CLUSTER ON "imported_rooms_pkey";

INSERT INTO "classify"."imported_rooms"
SELECT "value_numeric"::BIGINT,
       "unique_string"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = '_imported:_rooms'
   AND "type" = 'zset';

CREATE TABLE "classify"."imported_topics" (
	"tid" BIGINT NOT NULL PRIMARY KEY,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT,

	CHECK ("telligent_id" IS NOT NULL OR "discourse_id" IS NOT NULL)
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_topics" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_topics" ("discourse_id");

ALTER TABLE "classify"."imported_topics" CLUSTER ON "imported_topics_pkey";

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

CREATE TABLE "classify"."imported_users" (
	"uid" BIGINT NOT NULL PRIMARY KEY,
	"telligent_id" BIGINT,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

CREATE UNIQUE INDEX ON "classify"."imported_users" ("telligent_id");
CREATE UNIQUE INDEX ON "classify"."imported_users" ("discourse_id");

ALTER TABLE "classify"."imported_users" CLUSTER ON "imported_users_pkey";

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
