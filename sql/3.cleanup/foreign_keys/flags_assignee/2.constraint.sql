ALTER TABLE "flags"
  ADD CONSTRAINT "fk__flags__assignee"
      FOREIGN KEY ("assignee")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
