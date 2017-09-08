ALTER TABLE "topics"
  ADD CONSTRAINT "fk__topics__deleterUid"
      FOREIGN KEY ("deleterUid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
