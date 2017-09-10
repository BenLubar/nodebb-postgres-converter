ALTER TABLE "category_group_privileges"
  ADD CONSTRAINT "fk__category_group_privileges__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
