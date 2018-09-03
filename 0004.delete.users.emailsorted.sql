DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'email:sorted'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."email"
   AND uc."value_numeric" = 0;
