DELETE FROM "classify"."unclassified" uc
 USING "classify"."chat_room_users" cru
 WHERE uc."_key" = 'uid:' || cru."uid" || ':chat:rooms'
   AND uc."type" = 'zset'
   AND uc."unique_string" = cru."roomId"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM cru."added_at") * 1000)::NUMERIC;
