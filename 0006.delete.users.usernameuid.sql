DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'username:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."username"
   AND uc."value_numeric" = u."uid"::NUMERIC;
