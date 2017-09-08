ALTER TABLE "chat_messages"
  ADD CONSTRAINT "fk__chat_messages__fromuid"
      FOREIGN KEY ("fromuid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
