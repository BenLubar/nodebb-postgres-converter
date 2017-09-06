CREATE INDEX "idx__objects_legacy_tid__key__score_text"
    ON "objects_legacy_tid"("key0", "key1", ("score"::text));
