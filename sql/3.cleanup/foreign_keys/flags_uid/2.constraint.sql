ALTER TABLE "flags"
  ADD CONSTRAINT "fk__flags__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
