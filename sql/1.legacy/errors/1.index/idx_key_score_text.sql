CREATE INDEX "idx__objects_legacy_errors__key__score_text"
    ON "objects_legacy_errors"("key0", "key1", ("score"::text));
