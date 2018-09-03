DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'gdpr_consent'
   AND uc."value_string" = CASE WHEN u."gdpr_consent" THEN '1' ELSE '0' END;
