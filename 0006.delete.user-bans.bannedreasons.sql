DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_bans" ub
 WHERE uc."_key" = 'banned:' || ub."uid" || ':reasons'
   AND uc."type" = 'zset'
   AND uc."unique_string" = COALESCE(ub."reason", '')
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM ub."banned_at") * 1000)::NUMERIC;
