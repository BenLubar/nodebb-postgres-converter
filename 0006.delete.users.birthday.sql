DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'birthday'
   AND ((u."birthday" IS NULL AND uc."value_string" = '')
    OR  u."birthday" = "classify"."try_parse_date"(uc."value_string"));
