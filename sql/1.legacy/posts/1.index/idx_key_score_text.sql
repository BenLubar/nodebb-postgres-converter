CREATE INDEX "idx__objects_legacy_posts__key__score_text"
    ON "objects_legacy_posts"("key0", "key1", ("score"::text));
