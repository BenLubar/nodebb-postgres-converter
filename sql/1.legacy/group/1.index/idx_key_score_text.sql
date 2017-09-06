CREATE INDEX "idx__objects_legacy_group__key__score_text"
    ON "objects_legacy_group"("key0", "key1", ("score"::text));
