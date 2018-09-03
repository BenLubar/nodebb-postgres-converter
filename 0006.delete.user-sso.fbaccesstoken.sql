DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_sso" sso
 WHERE uc."_key" = 'user:' || sso."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'fbaccesstoken'
   AND uc."value_string" = sso."plugin_data"
   AND sso."plugin" = 'nodebb-plugin-sso-facebook';
