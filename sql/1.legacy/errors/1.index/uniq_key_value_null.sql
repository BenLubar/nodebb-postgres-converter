CREATE UNIQUE INDEX "uniq__objects_legacy_errors__key__value_null"
    ON "objects_legacy_errors"("key0", "key1")
 WHERE "value" IS NULL;
