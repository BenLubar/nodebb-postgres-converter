DELETE FROM "classify"."unclassified" uc
 USING "classify"."post_votes" pv
 WHERE uc."_key" = 'pid:' || pv."pid" || ':' || pv."type"
   AND uc."type" = 'set'
   AND uc."unique_string" = pv."uid"::TEXT;
