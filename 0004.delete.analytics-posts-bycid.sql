DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_posts_byCid" ap
 WHERE uc."_key" = 'analytics:posts:byCid:' || ap."cid"
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM ap."hour") * 1000)::TEXT
   AND uc."value_numeric" = ap."count"::NUMERIC;
