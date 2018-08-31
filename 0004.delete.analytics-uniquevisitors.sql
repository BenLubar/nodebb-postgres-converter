DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_uniquevisitors" av
 WHERE uc."_key" = 'analytics:uniquevisitors'
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM av."hour") * 1000)::TEXT
   AND uc."value_numeric" = av."count"::NUMERIC;
