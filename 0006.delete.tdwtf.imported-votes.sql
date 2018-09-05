-- useless
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = '_imported:_votes'
   AND uc."type" = 'zset'
   AND uc."unique_string" SIMILAR TO '[1-9][0-9]*';
