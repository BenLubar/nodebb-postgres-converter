DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'email:sorted'
   AND uc."type" = 'zset'
   AND uc."unique_string" = LOWER(u."email") || ':' || u."uid"
   AND uc."value_numeric" = 0;
