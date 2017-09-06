CREATE INDEX "idx__objects_legacy_email__key__score_text"
    ON "objects_legacy_email"("key0", "key1", ("score"::text));
