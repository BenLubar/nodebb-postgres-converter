CREATE UNIQUE INDEX "uniq__objects_legacy_analytics__key__value_null"
    ON "objects_legacy_analytics"("key0", "key1")
 WHERE "value" IS NULL;
