CREATE UNIQUE INDEX "uniq__objects_legacy_tid__key__value_null"
    ON "objects_legacy_tid"("key0", "key1")
 WHERE "value" IS NULL;
