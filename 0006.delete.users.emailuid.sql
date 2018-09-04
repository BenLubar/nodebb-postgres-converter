DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'email:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = LOWER(u."email")
   AND uc."value_numeric" = u."uid"::NUMERIC;
