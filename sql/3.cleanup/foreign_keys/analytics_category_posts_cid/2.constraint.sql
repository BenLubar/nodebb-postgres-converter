ALTER TABLE "analytics_category_posts"
  ADD CONSTRAINT "fk__analytics_category_posts__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
