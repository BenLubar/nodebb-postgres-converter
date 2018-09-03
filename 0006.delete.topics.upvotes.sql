DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'upvotes'
   AND uc."value_string" = t."upvotes"::TEXT;
