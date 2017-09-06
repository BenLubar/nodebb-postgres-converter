ALTER TABLE "posts" 
  ADD CONSTRAINT "fk__posts__deleterUid"
      FOREIGN KEY ("deleterUid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
