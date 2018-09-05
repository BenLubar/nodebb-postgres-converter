DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_bookmarks" ub
 WHERE uc."_key" = 'uid:' || ub."uid" || ':bookmarks'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ub."pid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM ub."bookmarked_at") * 1000)::NUMERIC;
