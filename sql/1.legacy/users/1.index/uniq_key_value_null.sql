CREATE UNIQUE INDEX "uniq__objects_legacy_users__key__value_null"
    ON "objects_legacy_users"("key0", "key1")
 WHERE "value" IS NULL;
