ALTER TABLE "group_members"
  ADD CONSTRAINT "fk__group_members__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
