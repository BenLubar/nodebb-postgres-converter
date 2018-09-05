DELETE FROM "classify"."unclassified" uc
 USING "classify"."sessions" s
 WHERE uc."_key" = 'uid:' || s."uid" || ':sessions'
   AND uc."type" = 'zset'
   AND uc."unique_string" = s."sid";
