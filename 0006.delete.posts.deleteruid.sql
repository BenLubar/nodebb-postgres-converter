DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'deleterUid'
   AND uc."value_string" = COALESCE(p."deleterUid", 0)::TEXT;
