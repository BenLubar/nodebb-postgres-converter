DELETE FROM "classify"."unclassified" uc
 USING "classify"."post_votes" pv
 WHERE uc."_key" = 'uid:' || pv."uid" || ':' || pv."type"
   AND uc."type" = 'zset'
   AND uc."unique_string" = pv."pid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM pv."timestamp") * 1000)::NUMERIC;
