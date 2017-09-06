CREATE INDEX "idx__objects_legacy_message__key__score"
    ON "objects_legacy_message"("key0", "key1", "score" DESC);
