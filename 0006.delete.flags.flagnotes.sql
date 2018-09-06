DELETE FROM "classify"."unclassified" uc
 USING "classify"."flag_notes" fn
 WHERE uc."_key" = 'flag:' || fn."flagId" || ':notes'
   AND uc."type" = 'zset'
   AND uc."unique_string"::JSONB = JSONB_BUILD_ARRAY(fn."uid", fn."note")
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM fn."datetime") * 1000)::NUMERIC;
