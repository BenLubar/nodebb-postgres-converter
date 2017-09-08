ALTER TABLE "post_votes"
  ADD CONSTRAINT "fk__post_votes__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
