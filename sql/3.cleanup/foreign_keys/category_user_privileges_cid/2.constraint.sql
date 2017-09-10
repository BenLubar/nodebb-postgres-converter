ALTER TABLE "category_user_privileges"
  ADD CONSTRAINT "fk__category_user_privileges__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
