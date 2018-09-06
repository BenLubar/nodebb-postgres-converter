DELETE FROM "classify"."unclassified" uc
 USING "classify"."flags" f
 WHERE uc."_key" = 'flag:' || f."flagId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'state'
   AND uc."value_string" = f."state"::TEXT;
