ALTER TABLE "topic_tags"
  ADD CONSTRAINT "fk__topic_tags__tid"
      FOREIGN KEY ("tid")
      REFERENCES "topics"("tid")
      ON DELETE CASCADE;
