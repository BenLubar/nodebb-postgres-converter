DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'deleted'
   AND uc."value_string" = CASE WHEN p."deleted" THEN '1' ELSE '0' END;
