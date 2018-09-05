CREATE TABLE "classify"."imported_rooms" (
	"roomId" BIGINT NOT NULL,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."imported_rooms"
SELECT "value_numeric"::BIGINT,
       "unique_string"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = '_imported:_rooms'
   AND "type" = 'zset';

ALTER TABLE "classify"."imported_rooms"
	ADD PRIMARY KEY ("roomId"),
	CLUSTER ON "imported_rooms_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_rooms" ("discourse_id");
