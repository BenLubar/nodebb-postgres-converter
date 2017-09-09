ALTER TABLE "flags"
  ADD CONSTRAINT "fk__flags__targetPid"
      FOREIGN KEY ("targetPid")
      REFERENCES "posts"("pid")
      ON DELETE CASCADE;
