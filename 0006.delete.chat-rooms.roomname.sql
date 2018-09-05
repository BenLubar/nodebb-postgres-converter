DELETE FROM "classify"."unclassified" uc
 USING "classify"."chat_rooms" cr
 WHERE uc."_key" = 'chat:room:' || cr."roomId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'roomName'
   AND uc."value_string" = COALESCE(cr."roomName", '');
