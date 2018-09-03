DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'twid'
   AND uc."value_string" = sso."externalID"
   AND sso."plugin" = 'nodebb-plugin-sso-twitter';
