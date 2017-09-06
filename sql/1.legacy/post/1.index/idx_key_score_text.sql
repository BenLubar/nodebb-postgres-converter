CREATE INDEX "idx__objects_legacy_post__key__score_text"
    ON "objects_legacy_post"("key0", "key1", ("score"::text));
