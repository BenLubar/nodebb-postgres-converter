ALTER TABLE "group_members"
  ADD CONSTRAINT "fk__group_members__groupName"
      FOREIGN KEY ("groupName")
      REFERENCES "groups"("name")
      ON DELETE CASCADE;
