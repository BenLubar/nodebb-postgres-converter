DELETE FROM "classify"."unclassified" uc
 USING "classify"."flags" f
 WHERE uc."_key" = 'flag:' || f."flagId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'datetime'
   AND uc."value_string" = (EXTRACT(EPOCH FROM f."datetime") * 1000)::TEXT;
