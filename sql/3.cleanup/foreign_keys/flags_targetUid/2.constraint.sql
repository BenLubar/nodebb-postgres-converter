ALTER TABLE "flags"
  ADD CONSTRAINT "fk__flags__targetUid"
      FOREIGN KEY ("targetUid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
