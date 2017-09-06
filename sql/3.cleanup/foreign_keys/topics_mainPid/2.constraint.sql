ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__mainPid"
      FOREIGN KEY ("mainPid")
      REFERENCES "posts"("pid")
      ON DELETE SET NULL;
