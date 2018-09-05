DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_topics" it
 WHERE uc."_key" = '_imported:_topics'
   AND uc."type" = 'zset'
   AND (uc."unique_string" = (it."discourse_id" * 2 + 1)::TEXT
    OR  uc."unique_string" = (it."telligent_id" * 2)::TEXT)
   AND uc."value_numeric" = it."tid"::NUMERIC;
