DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'post:' || p."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'ip'
   AND (uc."value_string" = COALESCE(HOST(p."ip"), '')
    OR  uc."value_string" LIKE HOST(p."ip") || ', %');
