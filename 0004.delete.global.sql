DELETE FROM "classify"."unclassified" uc
 USING "classify"."schemaDate" sd
 WHERE uc."_key" = 'schemaDate'
   AND uc."type" = 'string'
   AND uc."value_string" = sd."schemaDate";
