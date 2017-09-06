CREATE UNIQUE INDEX "uniq__objects_legacy_imported_set__key__value_null"
    ON "objects_legacy_imported_set"("key0", "key1")
 WHERE "value" IS NULL;
