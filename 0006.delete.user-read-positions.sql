DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_read_positions" urp
 WHERE uc."_key" = 'tid:' || urp."tid" || ':bookmarks'
   AND uc."type" = 'zset'
   AND uc."unique_string" = urp."uid"::TEXT
   AND uc."value_numeric" = urp."position"::NUMERIC;
