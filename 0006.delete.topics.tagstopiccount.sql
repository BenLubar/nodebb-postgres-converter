DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = 'tags:topic:count'
   AND uc."type" = 'zset';
