ALTER TABLE "chat_messages" 
  ADD CONSTRAINT "fk__chat_messages__roomId"
      FOREIGN KEY ("roomId")
      REFERENCES "chat_rooms"("roomId")
      ON DELETE CASCADE;
