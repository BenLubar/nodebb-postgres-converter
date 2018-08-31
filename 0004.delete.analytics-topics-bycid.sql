DELETE FROM "classify"."unclassified" uc
 USING "classify"."analytics_topics_byCid" at
 WHERE uc."_key" = 'analytics:topics:byCid:' || at."cid"
   AND uc."type" = 'zset'
   AND uc."unique_string" = (EXTRACT(EPOCH FROM at."hour") * 1000)::TEXT
   AND uc."value_numeric" = at."count"::NUMERIC;
