DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'fbid:uid'
   AND uc."type" = 'hash'
   AND uc."unique_string" = sso."externalID"
   AND uc."value_string" = sso."uid"::TEXT
   AND sso."plugin" = 'nodebb-plugin-sso-facebook';
