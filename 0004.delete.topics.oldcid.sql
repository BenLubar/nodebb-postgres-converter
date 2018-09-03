DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'oldCid'
   AND uc."value_string" = COALESCE(t."oldCid"::TEXT, '0');
