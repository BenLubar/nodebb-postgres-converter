CREATE INDEX "idx__objects_legacy_uid__key__score_text"
    ON "objects_legacy_uid"("key0", "key1", ("score"::text));
