ALTER TABLE "posts"
  ADD CONSTRAINT "fk__posts__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
