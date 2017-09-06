CREATE INDEX "idx__objects_legacy_imported_object__key__score_text"
    ON "objects_legacy_imported_object"("key0", "key1", ("score"::text));
