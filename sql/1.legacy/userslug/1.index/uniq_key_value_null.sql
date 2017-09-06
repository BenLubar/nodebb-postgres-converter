CREATE UNIQUE INDEX "uniq__objects_legacy_userslug__key__value_null"
    ON "objects_legacy_userslug"("key0", "key1")
 WHERE "value" IS NULL;
