DELETE FROM "classify"."unclassified" uc
 USING "classify"."tdwtf_post_cache" tpc
 WHERE uc."_key" = 'tdwtf-post-cache:' || tpc."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'content'
   AND uc."value_string" = tpc."content";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."tdwtf_post_cache" tpc
 WHERE uc."_key" = 'tdwtf-post-cache:' || tpc."pid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'version'
   AND uc."value_string" = tpc."version"::TEXT;
