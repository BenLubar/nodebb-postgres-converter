ALTER TABLE "analytics_category_pageviews"
  ADD CONSTRAINT "fk__analytics_category_pageviews__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
