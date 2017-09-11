ALTER TABLE "notifications"
  ADD CONSTRAINT "fk__notifications__from"
      FOREIGN KEY ("from")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
