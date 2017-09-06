ALTER TABLE "posts" 
  ADD CONSTRAINT "fk__posts__toPid"
      FOREIGN KEY ("toPid")
      REFERENCES "posts"("pid")
      ON DELETE SET NULL;
