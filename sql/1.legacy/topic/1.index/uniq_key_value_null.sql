CREATE UNIQUE INDEX "uniq__objects_legacy_topic__key__value_null"
    ON "objects_legacy_topic"("key0", "key1")
 WHERE "value" IS NULL;
