DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'cover:thumb:url'
   AND uc."value_string" = COALESCE(g."cover:thumb:url", '');
