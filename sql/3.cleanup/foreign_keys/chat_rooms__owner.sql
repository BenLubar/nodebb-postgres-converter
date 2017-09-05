UPDATE "chat_rooms"
   SET "owner" = NULL
  FROM "chat_rooms" t1
  LEFT OUTER JOIN "users" t2
    ON t1."owner" = t2."uid"
 WHERE t1."roomId" = "chat_rooms"."roomId"
   AND t2."uid" IS NULL
   AND t1."owner" IS NOT NULL;

ALTER TABLE "chat_rooms" 
  ADD CONSTRAINT "fk__chat_rooms__owner"
      FOREIGN KEY ("owner")
      REFERENCES "users"("uid")
      ON DELETE SET NULL;
