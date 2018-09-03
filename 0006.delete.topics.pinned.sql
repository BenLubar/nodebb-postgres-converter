DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'pinned'
   AND uc."value_string" = CASE WHEN t."pinned" THEN '1' ELSE '0' END;
