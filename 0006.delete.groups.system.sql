DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'system'
   AND uc."value_string" = CASE WHEN g."system" THEN '1' ELSE '0' END;
