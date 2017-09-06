CREATE INDEX "idx__objects_legacy_user__key__score_text"
    ON "objects_legacy_user"("key0", "key1", ("score"::text));
