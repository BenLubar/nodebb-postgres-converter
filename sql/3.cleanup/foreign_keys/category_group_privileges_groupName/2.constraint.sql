ALTER TABLE "category_group_privileges"
  ADD CONSTRAINT "fk__category_group_privileges__groupName"
      FOREIGN KEY ("groupName")
      REFERENCES "groups"("name")
      ON DELETE CASCADE;
