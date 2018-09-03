DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_pageviews_byCid" ap
 WHERE uc."_key" = 'analytics:pageviews:byCid:' || ap."cid"
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM ap."hour") * 1000)::TEXT
   AND uc."value_numeric" = ap."count"::NUMERIC;
