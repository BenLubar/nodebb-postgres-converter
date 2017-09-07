ALTER TABLE "user_ips"
  ADD CONSTRAINT "fk__user_ips__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
