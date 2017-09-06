CREATE INDEX "idx__objects_legacy_notifications__key__score_text"
    ON "objects_legacy_notifications"("key0", "key1", ("score"::text));
