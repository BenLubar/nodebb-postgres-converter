ALTER TABLE "user_notifications"
  ADD CONSTRAINT "fk__user_notifications__nid"
      FOREIGN KEY ("nid")
      REFERENCES "notifications"("nid")
      ON DELETE CASCADE;
