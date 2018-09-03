DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topics:posts'
   AND uc."type" = 'zset'
   AND uc."unique_string" = t."tid"::TEXT
   AND uc."value_numeric" = t."postcount";
