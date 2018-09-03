DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'deletedTimestamp'
   AND uc."value_string" = (EXTRACT(EPOCH FROM t."deletedTimestamp") * 1000)::TEXT;
