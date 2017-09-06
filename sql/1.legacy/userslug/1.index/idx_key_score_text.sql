CREATE INDEX "idx__objects_legacy_userslug__key__score_text"
    ON "objects_legacy_userslug"("key0", "key1", ("score"::text));
