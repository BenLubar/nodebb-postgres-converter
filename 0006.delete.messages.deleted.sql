DELETE FROM "classify"."unclassified" uc
 USING "classify"."messages" m
 WHERE uc."_key" = 'message:' || m."mid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'deleted'
   AND uc."value_string" = CASE WHEN m."deleted" THEN '1' ELSE '0' END;
