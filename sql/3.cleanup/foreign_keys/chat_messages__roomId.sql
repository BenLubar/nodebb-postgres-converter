DELETE FROM "chat_messages"
 USING "chat_messages" t1
  LEFT OUTER JOIN "chat_rooms" t2
    ON t1."roomId" = t2."roomId"
 WHERE t1."mid" = "chat_messages"."mid"
   AND t2."roomId" IS NULL
   AND t1."roomId" IS NOT NULL;

ALTER TABLE "chat_messages" 
  ADD CONSTRAINT "fk__chat_messages__roomId"
      FOREIGN KEY ("roomId")
      REFERENCES "chat_rooms"("roomId")
      ON DELETE CASCADE;
