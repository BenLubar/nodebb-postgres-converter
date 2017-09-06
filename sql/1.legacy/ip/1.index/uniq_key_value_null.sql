CREATE UNIQUE INDEX "uniq__objects_legacy_ip__key__value_null"
    ON "objects_legacy_ip"("key0", "key1")
 WHERE "value" IS NULL;
