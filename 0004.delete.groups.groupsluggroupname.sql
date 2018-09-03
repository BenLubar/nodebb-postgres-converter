DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groupslug:groupname'
   AND uc."type" = 'hash'
   AND uc."unique_string" = g."slug"
   AND uc."value_string" = g."name";
