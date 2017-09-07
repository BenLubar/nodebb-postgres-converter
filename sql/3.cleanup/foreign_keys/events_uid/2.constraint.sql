ALTER TABLE "events"
  ADD CONSTRAINT "fk__events__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
