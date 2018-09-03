DELETE FROM "classify"."unclassified" uc
 USING "classify"."errors_404" e
 WHERE uc."_key" = 'errors:404'
   AND uc."type" = 'zset'
   AND uc."unique_string" = e."path"
   AND uc."value_numeric" = e."count"::NUMERIC;
