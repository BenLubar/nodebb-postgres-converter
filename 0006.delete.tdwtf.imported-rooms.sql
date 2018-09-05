DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_rooms" ir
 WHERE uc."_key" = '_imported:_rooms'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ir."discourse_id"::TEXT
   AND uc."value_numeric" = ir."roomId"::NUMERIC;
