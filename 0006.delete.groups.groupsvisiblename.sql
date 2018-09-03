DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:name'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = 0
   AND NOT g."hidden";
