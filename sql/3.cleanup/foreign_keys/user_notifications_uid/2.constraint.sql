ALTER TABLE "user_notifications"
  ADD CONSTRAINT "fk__user_notifications__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
