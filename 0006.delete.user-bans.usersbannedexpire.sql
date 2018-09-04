DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_bans" ub
 WHERE uc."_key" = 'users:banned:expire'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ub."uid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM ub."expires_at") * 1000)::NUMERIC;
