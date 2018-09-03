DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'tid:' || p."tid" || ':posts'
   AND uc."type" = 'zset'
   AND uc."unique_string" = p."pid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM p."timestamp") / 1000)::NUMERIC;
