CREATE UNIQUE INDEX "uniq__objects_legacy_message__key__value_null"
    ON "objects_legacy_message"("key0", "key1")
 WHERE "value" IS NULL;
