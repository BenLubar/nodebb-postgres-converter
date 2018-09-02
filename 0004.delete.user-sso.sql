DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'fbid'
   AND uc."value_string" = sso."externalID"
   AND sso."plugin" = 'nodebb-plugin-sso-facebook';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'fbid:uid'
   AND uc."type" = 'hash'
   AND uc."unique_string" = sso."externalID"
   AND uc."value_string" = sso."uid"::TEXT
   AND sso."plugin" = 'nodebb-plugin-sso-facebook';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'fbaccesstoken'
   AND uc."value_string" = sso."plugin_data"
   AND sso."plugin" = 'nodebb-plugin-sso-facebook';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'githubid'
   AND uc."value_string" = sso."externalID"
   AND sso."plugin" = 'nodebb-plugin-sso-github';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'githubid:uid'
   AND uc."type" = 'hash'
   AND uc."unique_string" = sso."externalID"
   AND uc."value_string" = sso."uid"::TEXT
   AND sso."plugin" = 'nodebb-plugin-sso-github';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'gplusid'
   AND uc."value_string" = sso."externalID"
   AND sso."plugin" = 'nodebb-plugin-sso-google';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'gplusid:uid'
   AND uc."type" = 'hash'
   AND uc."unique_string" = sso."externalID"
   AND uc."value_string" = sso."uid"::TEXT
   AND sso."plugin" = 'nodebb-plugin-sso-google';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'twid'
   AND uc."value_string" = sso."externalID"
   AND sso."plugin" = 'nodebb-plugin-sso-twitter';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'twid:uid'
   AND uc."type" = 'hash'
   AND uc."unique_string" = sso."externalID"
   AND uc."value_string" = sso."uid"::TEXT
   AND sso."plugin" = 'nodebb-plugin-sso-twitter';
