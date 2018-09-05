DELETE FROM "classify"."unclassified" uc
 USING "classify"."messages" m
 WHERE uc."_key" = 'message:' || m."mid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'roomId'
   AND uc."value_string" = m."roomId"::TEXT;
