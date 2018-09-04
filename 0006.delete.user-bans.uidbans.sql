DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_bans" ub
 WHERE uc."_key" = 'uid:' || ub."uid" || ':bans'
   AND uc."type" = 'zset'
   AND uc."unique_string" = COALESCE(EXTRACT(EPOCH FROM ub."expires_at") * 1000, 0)::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM ub."banned_at") * 1000)::NUMERIC;
