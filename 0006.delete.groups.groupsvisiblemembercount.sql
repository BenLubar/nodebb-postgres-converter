DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:memberCount'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = g."memberCount"
   AND NOT g."hidden";
