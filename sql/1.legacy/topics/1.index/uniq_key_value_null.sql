CREATE UNIQUE INDEX "uniq__objects_legacy_topics__key__value_null"
    ON "objects_legacy_topics"("key0", "key1")
 WHERE "value" IS NULL;
