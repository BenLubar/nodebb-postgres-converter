DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_posts" ip
 WHERE uc."_key" = '_imported:_posts'
   AND uc."type" = 'zset'
   AND (uc."unique_string" = (ip."discourse_id" * 2 + 1)::TEXT
    OR  uc."unique_string" = (ip."telligent_id" * 2)::TEXT)
   AND uc."value_numeric" = ip."pid"::NUMERIC;
