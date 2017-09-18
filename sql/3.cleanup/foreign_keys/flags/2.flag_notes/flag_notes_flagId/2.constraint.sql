ALTER TABLE "flag_notes"
  ADD CONSTRAINT "fk__flag_notes__flagId"
      FOREIGN KEY ("flagId")
      REFERENCES "flags"("flagId")
      ON DELETE CASCADE;
