ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__teaserPid"
      FOREIGN KEY ("teaserPid")
      REFERENCES "posts"("pid")
      ON DELETE SET NULL;
