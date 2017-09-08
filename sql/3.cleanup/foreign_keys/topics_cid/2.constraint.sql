ALTER TABLE "topics"
  ADD CONSTRAINT "fk__topics__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
