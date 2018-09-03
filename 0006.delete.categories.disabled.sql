DELETE FROM "classify"."unclassified" uc
 USING "classify"."categories" c
 WHERE uc."_key" = 'category:' || c."cid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'disabled'
   AND uc."value_string" = CASE WHEN c."disabled" THEN '1' ELSE '0' END;
