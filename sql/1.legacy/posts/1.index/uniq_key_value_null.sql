CREATE UNIQUE INDEX "uniq__objects_legacy_posts__key__value_null"
    ON "objects_legacy_posts"("key0", "key1")
 WHERE "value" IS NULL;
