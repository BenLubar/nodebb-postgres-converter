CREATE UNIQUE INDEX "uniq__objects_legacy_post__key__value" ON "objects_legacy_post"("key0", "key1", "value");
CREATE INDEX "idx__objects_legacy_post__key__score" ON "objects_legacy_post"("key0", "key1", "score" DESC);
CREATE INDEX "idx__objects_legacy_post__key__score_text" ON "objects_legacy_post"("key0", "key1", ("score"::text));

CLUSTER "objects_legacy_post" USING "uniq__objects_legacy_post__key__value";

ANALYZE "objects_legacy_post";
