DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'rss_token'
   AND uc."value_string" = COALESCE(u."rss_token"::TEXT, '');
