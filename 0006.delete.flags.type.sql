DELETE FROM "classify"."unclassified" uc
 USING "classify"."flags" f
 WHERE uc."_key" = 'flag:' || f."flagId"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'type'
   AND uc."value_string" =
       CASE WHEN f."targetPid" IS NOT NULL THEN 'post'
            WHEN f."targetUid" IS NOT NULL THEN 'user'
       END;
