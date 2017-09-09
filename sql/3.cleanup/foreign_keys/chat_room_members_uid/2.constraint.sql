ALTER TABLE "chat_room_members"
  ADD CONSTRAINT "fk__chat_room_members__uid"
      FOREIGN KEY ("uid")
      REFERENCES "users"("uid")
      ON DELETE CASCADE;
