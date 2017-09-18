ALTER TABLE "flag_notes"
  ADD CONSTRAINT "fk__flag_notes__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
