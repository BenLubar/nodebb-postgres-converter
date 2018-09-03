DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'banned'
   AND uc."value_string" = CASE WHEN u."banned" THEN '1' ELSE '0' END;
