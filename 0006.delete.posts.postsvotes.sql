DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'posts:votes'
   AND uc."type" = 'zset'
   AND uc."unique_string" = p."pid"::TEXT
   AND uc."value_numeric" = p."votes"::NUMERIC;
