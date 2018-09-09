DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'user:' || g."name" || ':settings'
   AND uc."type" = 'hash';
