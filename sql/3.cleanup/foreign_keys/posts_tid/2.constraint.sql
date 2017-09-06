ALTER TABLE "posts" 
  ADD CONSTRAINT "fk__posts__tid"
      FOREIGN KEY ("tid")
      REFERENCES "topics"("tid")
      ON DELETE CASCADE;
