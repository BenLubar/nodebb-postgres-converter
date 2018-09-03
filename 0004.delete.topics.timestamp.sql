DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'timestamp'
   AND uc."value_string" = (EXTRACT(EPOCH FROM t."timestamp") * 1000)::TEXT;
