CREATE UNIQUE INDEX "uniq__objects_legacy_cid__key__value_null"
    ON "objects_legacy_cid"("key0", "key1")
 WHERE "value" IS NULL;
