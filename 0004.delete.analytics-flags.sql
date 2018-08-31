DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_flags" af
 WHERE uc."_key" = 'analytics:flags'
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM af."hour") * 1000)::TEXT
   AND uc."value_numeric" = af."count"::NUMERIC;
