DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topics:tid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = t."tid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM t."timestamp") * 1000)::NUMERIC;
