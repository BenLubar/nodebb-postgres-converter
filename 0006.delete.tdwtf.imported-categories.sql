DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_categories" ic
 WHERE uc."_key" = '_imported:_categories'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ic."discourse_id"::TEXT
   AND uc."value_numeric" = ic."cid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_categories" ic
 WHERE uc."_key" = '_telligent:_categories'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ic."telligent_id"::TEXT
   AND uc."value_numeric" = ic."discourse_id"::NUMERIC;
