CREATE TABLE "classify"."imported_messages" (
	"mid" BIGINT NOT NULL,
	"discourse_id" BIGINT NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."imported_messages"
SELECT "value_numeric"::BIGINT,
       "unique_string"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" = '_imported:_messages'
   AND "type" = 'zset';

ALTER TABLE "classify"."imported_messages"
	ADD PRIMARY KEY ("mid"),
	CLUSTER ON "imported_messages_pkey";
CREATE UNIQUE INDEX ON "classify"."imported_messages" ("discourse_id");
