ALTER TABLE "chat_room_members"
  ADD CONSTRAINT "fk__chat_room_members__roomId"
      FOREIGN KEY ("roomId")
      REFERENCES "chat_rooms"("roomId")
      ON DELETE CASCADE;
