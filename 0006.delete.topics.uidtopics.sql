DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'uid:' || t."uid" || ':topics'
   AND uc."type" = 'zset'
   AND uc."unique_string" = t."tid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM t."timestamp") * 1000)::NUMERIC;
