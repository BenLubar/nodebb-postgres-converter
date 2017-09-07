ALTER TABLE "user_usernames"
  ADD CONSTRAINT "fk__user_usernames__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
