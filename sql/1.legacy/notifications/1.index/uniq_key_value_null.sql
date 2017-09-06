CREATE UNIQUE INDEX "uniq__objects_legacy_notifications__key__value_null"
    ON "objects_legacy_notifications"("key0", "key1")
 WHERE "value" IS NULL;
