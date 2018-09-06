DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 CROSS JOIN UNNEST(t."tags") tag("name")
 WHERE uc."_key" = 'tag:' || tag."name" || ':topics'
   AND uc."type" = 'zset'
   AND uc."unique_string" = t."tid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM t."timestamp") * 1000)::NUMERIC;
