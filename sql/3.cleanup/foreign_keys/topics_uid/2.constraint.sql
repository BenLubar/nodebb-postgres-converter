ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
