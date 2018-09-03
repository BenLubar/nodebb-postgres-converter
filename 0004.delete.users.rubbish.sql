-- Delete rubbish
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" IN ('user:-1', 'user:0', 'user:undefined')
   AND uc."type" = 'hash';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'user:' || g."name"
   AND uc."type" = 'hash';
