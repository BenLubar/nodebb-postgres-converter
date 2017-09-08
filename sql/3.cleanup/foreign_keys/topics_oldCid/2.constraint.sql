ALTER TABLE "topics"
  ADD CONSTRAINT "fk__topics__oldCid"
      FOREIGN KEY ("oldCid")
      REFERENCES "categories"("cid")
      ON DELETE SET NULL;
