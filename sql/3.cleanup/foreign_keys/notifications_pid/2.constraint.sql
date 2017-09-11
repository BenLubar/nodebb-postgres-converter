ALTER TABLE "notifications"
  ADD CONSTRAINT "fk__notifications__pid"
      FOREIGN KEY ("pid")
      REFERENCES "posts"("pid")
      ON DELETE CASCADE;
