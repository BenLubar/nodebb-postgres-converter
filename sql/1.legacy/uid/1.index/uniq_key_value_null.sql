CREATE UNIQUE INDEX "uniq__objects_legacy_uid__key__value_null"
    ON "objects_legacy_uid"("key0", "key1")
 WHERE "value" IS NULL;
