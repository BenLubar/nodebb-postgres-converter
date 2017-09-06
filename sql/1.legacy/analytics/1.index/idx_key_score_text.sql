CREATE INDEX "idx__objects_legacy_analytics__key__score_text"
    ON "objects_legacy_analytics"("key0", "key1", ("score"::text));
