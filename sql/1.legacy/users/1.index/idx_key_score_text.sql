CREATE INDEX "idx__objects_legacy_users__key__score_text"
    ON "objects_legacy_users"("key0", "key1", ("score"::text));
