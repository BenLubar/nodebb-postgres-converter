CREATE INDEX "idx__objects_legacy_topics__key__score"
    ON "objects_legacy_topics"("key0", "key1", "score" DESC);