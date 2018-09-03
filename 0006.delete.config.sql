DELETE FROM "classify"."unclassified" uc
 USING "classify"."config" c
 WHERE uc."type" = 'hash'
   AND CASE c."plugin"
       WHEN '' THEN
            CASE c."key"
            WHEN 'ip-blacklist-rules' THEN
                 uc."_key" = 'ip-blacklist-rules'
             AND uc."unique_string" = 'rules'
            ELSE uc."_key" = 'config'
             AND uc."unique_string" = c."key"
            END
       ELSE uc."_key" = 'settings:' || c."plugin"
        AND uc."unique_string" = c."key"
       END
   AND uc."value_string" = c."value";
