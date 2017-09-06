CREATE INDEX "idx__objects_legacy_pid__key__score_text"
    ON "objects_legacy_pid"("key0", "key1", ("score"::text));
