DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'passwordExpiry'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."passwordExpiry") * 1000, 0)::TEXT;
