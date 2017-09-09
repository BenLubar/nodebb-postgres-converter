DELETE FROM "chat_room_members"
 USING "chat_room_members" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "chat_room_members"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
