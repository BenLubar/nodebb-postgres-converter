DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 WHERE uc."_key" = 'tid:' || p."tid" || ':posters'
   AND uc."type" = 'zset'
   AND uc."unique_string" = p."uid"::TEXT;
