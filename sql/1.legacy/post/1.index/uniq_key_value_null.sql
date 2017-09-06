CREATE UNIQUE INDEX "uniq__objects_legacy_post__key__value_null"
    ON "objects_legacy_post"("key0", "key1")
 WHERE "value" IS NULL;
