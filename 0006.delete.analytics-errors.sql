DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_errors" ae
 WHERE uc."_key" = 'analytics:errors:' || ae."http_status"
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM ae."hour") * 1000)::TEXT
   AND uc."value_numeric" = ae."count"::NUMERIC;
