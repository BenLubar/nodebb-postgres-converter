ALTER TABLE "notifications"
  ADD CONSTRAINT "fk__notifications__tid"
      FOREIGN KEY ("tid")
      REFERENCES "topics"("tid")
      ON DELETE CASCADE;
