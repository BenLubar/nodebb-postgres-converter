CREATE INDEX "idx__objects_legacy_misc__key__score_text"
    ON "objects_legacy_misc"("key0", "key1", ("score"::text));
