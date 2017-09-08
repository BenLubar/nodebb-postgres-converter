CREATE TABLE "topic_tags" (
	"tid" bigint NOT NULL,
	"tag" text NOT NULL
);

INSERT INTO "topic_tags" SELECT
       i."value"::bigint "tid",
       jsonb_array_elements_text(t."data"->'members') "tag"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" t
    ON t."key0" = 'topic'
   AND t."key1" = ARRAY[i."value", 'tags']
 WHERE i."key0" = 'topics'
   AND i."key1" = ARRAY['tid'];

ALTER TABLE "topic_tags" ADD PRIMARY KEY ("tid", "tag");

CREATE INDEX "idx__topic_tags__tag" ON "topic_tags"("tag");

ALTER TABLE "topic_tags"
      CLUSTER ON "topic_tags_pkey";
