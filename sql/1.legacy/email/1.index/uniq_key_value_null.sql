CREATE UNIQUE INDEX "uniq__objects_legacy_email__key__value_null"
    ON "objects_legacy_email"("key0", "key1")
 WHERE "value" IS NULL;
