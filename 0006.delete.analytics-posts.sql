DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_posts" ap
 WHERE uc."_key" = 'analytics:posts'
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM ap."hour") * 1000)::TEXT
   AND uc."value_numeric" = ap."count"::NUMERIC;
