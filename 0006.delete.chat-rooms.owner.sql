DELETE FROM "classify"."unclassified" uc
 USING "classify"."chat_rooms" cr
 WHERE uc."_key" = 'chat:room:' || cr."roomId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'owner'
   AND (uc."value_string" = cr."owner"::TEXT
    OR (cr."owner" IS NULL AND (uc."value_string" = '' OR uc."value_string" = '0')));
