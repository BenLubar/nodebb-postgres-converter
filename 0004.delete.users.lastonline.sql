DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'lastonline'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."lastonline") * 1000, 0)::TEXT;
