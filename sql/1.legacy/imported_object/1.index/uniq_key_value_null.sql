CREATE UNIQUE INDEX "uniq__objects_legacy_imported_object__key__value_null"
    ON "objects_legacy_imported_object"("key0", "key1")
 WHERE "value" IS NULL;
