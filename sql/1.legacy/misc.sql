CREATE UNIQUE INDEX "uniq__objects_legacy_misc__key__value" ON "objects_legacy_misc"("key0", "key1", "value");
CREATE INDEX "idx__objects_legacy_misc__key__score" ON "objects_legacy_misc"("key0", "key1", "score" DESC);
CREATE INDEX "idx__objects_legacy_misc__key__score_text" ON "objects_legacy_misc"("key0", "key1", ("score"::text));

CLUSTER "objects_legacy_misc" USING "uniq__objects_legacy_misc__key__value";

ANALYZE "objects_legacy_misc";
