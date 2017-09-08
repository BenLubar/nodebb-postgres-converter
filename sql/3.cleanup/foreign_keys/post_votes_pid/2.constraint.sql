ALTER TABLE "post_votes"
  ADD CONSTRAINT "fk__post_votes__pid"
      FOREIGN KEY ("pid")
      REFERENCES "posts"("pid")
      ON DELETE CASCADE;
