DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_messages" im
 WHERE uc."_key" = '_imported:_messages'
   AND uc."type" = 'zset'
   AND uc."unique_string" = im."discourse_id"::TEXT
   AND uc."value_numeric" = im."mid"::NUMERIC;
