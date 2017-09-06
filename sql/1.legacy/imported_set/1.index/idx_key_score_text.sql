CREATE INDEX "idx__objects_legacy_imported_set__key__score_text"
    ON "objects_legacy_imported_set"("key0", "key1", ("score"::text));
