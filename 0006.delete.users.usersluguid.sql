DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'userslug:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."userslug"
   AND uc."value_numeric" = u."uid"::NUMERIC;
