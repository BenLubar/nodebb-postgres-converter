CREATE UNIQUE INDEX "uniq__objects_legacy_user__key__value_null"
    ON "objects_legacy_user"("key0", "key1")
 WHERE "value" IS NULL;
