CREATE INDEX "idx__objects_legacy_ip__key__score_text"
    ON "objects_legacy_ip"("key0", "key1", ("score"::text));
