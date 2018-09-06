DELETE FROM "classify"."unclassified" uc
 USING "classify"."topics" t
 WHERE uc."_key" = 'topic:' || t."tid" || ':tags'
   AND uc."type" = 'set'
   AND uc."unique_string" = ANY(t."tags");
