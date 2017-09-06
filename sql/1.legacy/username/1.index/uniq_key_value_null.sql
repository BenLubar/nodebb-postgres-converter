CREATE UNIQUE INDEX "uniq__objects_legacy_username__key__value_null"
    ON "objects_legacy_username"("key0", "key1")
 WHERE "value" IS NULL;
