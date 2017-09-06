CREATE INDEX "idx__objects_legacy_cid__key__score_text"
    ON "objects_legacy_cid"("key0", "key1", ("score"::text));
