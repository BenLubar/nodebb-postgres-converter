DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_users" iu
 WHERE uc."_key" = '_imported:_users'
   AND uc."type" = 'zset'
   AND uc."unique_string" = iu."discourse_id"::TEXT
   AND uc."value_numeric" = iu."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_users" iu
 WHERE uc."_key" = '_telligent:_users'
   AND uc."type" = 'zset'
   AND uc."unique_string" = iu."telligent_id"::TEXT
   AND uc."value_numeric" = iu."discourse_id"::NUMERIC;
