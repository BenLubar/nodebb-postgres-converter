ALTER TABLE "category_user_privileges"
  ADD CONSTRAINT "fk__category_user_privileges__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
