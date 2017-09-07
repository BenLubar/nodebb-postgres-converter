ALTER TABLE "user_emails"
  ADD CONSTRAINT "fk__user_emails__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
