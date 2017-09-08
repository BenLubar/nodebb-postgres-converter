ALTER TABLE "posts"
  ADD CONSTRAINT "fk__posts__editor"
      FOREIGN KEY ("editor")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
