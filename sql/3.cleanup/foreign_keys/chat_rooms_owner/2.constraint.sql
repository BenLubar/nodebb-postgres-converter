ALTER TABLE "chat_rooms"
  ADD CONSTRAINT "fk__chat_rooms__owner"
      FOREIGN KEY ("owner")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
