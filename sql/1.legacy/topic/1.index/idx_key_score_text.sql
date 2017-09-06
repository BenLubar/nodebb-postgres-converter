CREATE INDEX "idx__objects_legacy_topic__key__score_text"
    ON "objects_legacy_topic"("key0", "key1", ("score"::text));
