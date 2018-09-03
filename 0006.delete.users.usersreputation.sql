DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'users:reputation'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."uid"::TEXT
   AND uc."value_numeric" = u."reputation"::NUMERIC;
