CREATE INDEX "idx__objects_legacy_username__key__score_text"
    ON "objects_legacy_username"("key0", "key1", ("score"::text));
