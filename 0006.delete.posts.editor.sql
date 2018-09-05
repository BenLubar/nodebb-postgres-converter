DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'editor'
   AND (uc."value_string" = COALESCE(p."editor", 0)::TEXT
    OR (uc."value_string" = '' AND p."editor" IS NULL));
