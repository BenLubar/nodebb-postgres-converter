UPDATE "chat_messages"
   SET "fromuid" = NULL
  FROM "chat_messages" t1
  LEFT OUTER JOIN "users" t2
    ON t1."fromuid" = t2."uid"
 WHERE t1."mid" = "chat_messages"."mid"
   AND t2."uid" IS NULL
   AND t1."fromuid" IS NOT NULL;

ALTER TABLE "chat_messages" 
  ADD CONSTRAINT "fk__chat_messages__fromuid"
      FOREIGN KEY ("fromuid")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
