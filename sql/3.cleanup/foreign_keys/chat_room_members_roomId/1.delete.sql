DELETE FROM "chat_room_members"
 USING "chat_room_members" t1
  LEFT OUTER JOIN "chat_rooms" t2
    ON t1."roomId" = t2."roomId"
 WHERE t1."roomId" = "chat_room_members"."roomId"
   AND t2."roomId" IS NULL
   AND t1."roomId" IS NOT NULL;
