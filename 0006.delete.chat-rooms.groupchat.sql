DELETE FROM "classify"."unclassified" uc
 USING "classify"."chat_rooms" cr
 WHERE uc."_key" = 'chat:room:' || cr."roomId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'groupChat'
   AND uc."value_string" = CASE WHEN cr."groupChat" THEN '1' ELSE '0' END;
