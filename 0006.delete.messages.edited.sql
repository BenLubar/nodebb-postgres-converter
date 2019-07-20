DELETE FROM "classify"."unclassified" uc
 USING "classify"."messages" m
 WHERE uc."_key" = 'message:' || m."mid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'edited'
   AND uc."value_string" = (EXTRACT(EPOCH FROM m."edited") * 1000)::TEXT;
