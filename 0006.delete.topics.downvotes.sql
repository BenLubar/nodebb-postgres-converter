DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'downvotes'
   AND uc."value_string" = t."downvotes"::TEXT;
