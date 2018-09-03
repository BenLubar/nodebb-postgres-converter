DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'edited'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM p."edited") * 1000, 0)::TEXT;
