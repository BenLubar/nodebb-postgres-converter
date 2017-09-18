CREATE TABLE "flag_notes" (
	"flagId" bigint NOT NULL,
	"uid" bigint,
	"content" text NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW()
) WITH (autovacuum_enabled = false);

INSERT INTO "flag_notes" SELECT
       i."value"::bigint "flagId",
       (n."value"::jsonb->>0)::bigint "uid",
       (n."value"::jsonb->>1) "content",
       to_timestamp(n."score"::double precision / 1000) "timestamp"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" n
    ON n."key0" = 'flag'
   AND n."key1" = ARRAY[i."value", 'notes']
 WHERE i."key0" = 'flags'
   AND i."key1" = ARRAY['datetime'];

CREATE INDEX "idx__flag_notes__flagId__timestamp" ON "flag_notes"("flagId", "timestamp");

CREATE INDEX "idx__flag_notes__uid" ON "flag_notes"("uid");

ALTER TABLE "flag_notes"
      CLUSTER ON "idx__flag_notes__flagId__timestamp";
