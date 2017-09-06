CREATE UNIQUE INDEX "uniq__objects_legacy_group__key__value_null"
    ON "objects_legacy_group"("key0", "key1")
 WHERE "value" IS NULL;
