CREATE TABLE "classify"."schemaDate" (
	"schemaDate" TEXT COLLATE "C" NOT NULL
)
WITHOUT OIDS;

-- only one row allowed
CREATE UNIQUE INDEX ON "classify"."schemaDate" ((TRUE));

INSERT INTO "classify"."schemaDate"
SELECT "value_string"
  FROM "classify"."unclassified"
 WHERE "_key" = 'schemaDate'
   AND "type" = 'string';
