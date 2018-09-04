DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_bans" ub
 WHERE uc."_key" = 'users:banned'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ub."uid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM ub."banned_at") * 1000)::NUMERIC;
