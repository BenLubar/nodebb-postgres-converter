DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'timestamp'
   AND uc."value_string" = (EXTRACT(EPOCH FROM p."timestamp") * 1000)::TEXT;
