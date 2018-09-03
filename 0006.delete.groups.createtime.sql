DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'createtime'
   AND uc."value_string" = (EXTRACT(EPOCH FROM g."createtime") * 1000)::TEXT;
