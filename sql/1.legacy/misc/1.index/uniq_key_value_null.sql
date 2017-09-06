CREATE UNIQUE INDEX "uniq__objects_legacy_misc__key__value_null"
    ON "objects_legacy_misc"("key0", "key1")
 WHERE "value" IS NULL;
