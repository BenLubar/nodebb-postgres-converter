DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'users:joindate'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."uid"::TEXT
   AND uc."value_numeric" = COALESCE(EXTRACT(EPOCH FROM u."joindate") * 1000, 0)::NUMERIC;
