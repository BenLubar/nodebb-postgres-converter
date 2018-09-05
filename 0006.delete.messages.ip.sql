DELETE FROM "classify"."unclassified" uc
 USING "classify"."messages" m
 WHERE uc."_key" = 'message:' || m."mid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'ip'
   AND SPLIT_PART(uc."value_string", ',', 1) = HOST(m."ip");
