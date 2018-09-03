DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:createtime'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM g."createtime") * 1000)::NUMERIC
   AND NOT g."hidden";
