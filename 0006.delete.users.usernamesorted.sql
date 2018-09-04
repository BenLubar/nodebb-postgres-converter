DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'username:sorted'
   AND uc."type" = 'zset'
   AND uc."unique_string" = LOWER(u."username") || ':' || u."uid"
   AND uc."value_numeric" = 0;
