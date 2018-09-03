DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'fullname:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."fullname"
   AND uc."value_numeric" = u."uid"::NUMERIC;
