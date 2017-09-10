ALTER TABLE "analytics_category_topics"
  ADD CONSTRAINT "fk__analytics_category_topics__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
