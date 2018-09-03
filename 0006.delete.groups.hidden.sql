DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'hidden'
   AND uc."value_string" = CASE WHEN g."hidden" THEN '1' ELSE '0' END;
