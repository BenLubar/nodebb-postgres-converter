DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'icon'
   AND uc."value_string" = COALESCE(g."icon", '');
