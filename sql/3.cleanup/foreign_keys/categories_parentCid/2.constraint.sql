ALTER TABLE "categories" 
  ADD CONSTRAINT "fk__categories__parentCid"
      FOREIGN KEY ("parentCid")
      REFERENCES "categories"("cid")
      ON DELETE SET NULL;
