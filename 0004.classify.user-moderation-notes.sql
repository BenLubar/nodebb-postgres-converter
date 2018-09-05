CREATE TABLE "classify"."user_moderation_notes" (
	"note_id" BIGSERIAL NOT NULL,
	"uid" BIGINT NOT NULL,
	"moderator_id" BIGINT NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"note" TEXT COLLATE "C" NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."user_moderation_notes"
SELECT NEXTVAL('classify.user_moderation_notes_note_id_seq'::REGCLASS),
       SPLIT_PART("_key", ':', 2)::BIGINT,
       ("unique_string"::JSONB->>'uid')::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       "unique_string"::JSONB->>'note'
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:moderation:notes'
   AND "type" = 'zset';

ALTER TABLE "classify"."user_moderation_notes"
	ADD PRIMARY KEY ("note_id"),
	CLUSTER ON "user_moderation_notes_pkey";
CREATE INDEX ON "classify"."user_moderation_notes"("uid", "timestamp");
