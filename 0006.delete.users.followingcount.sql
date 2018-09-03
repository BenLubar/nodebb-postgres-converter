DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'followingCount'
   AND uc."value_string" = u."followingCount"::TEXT;
