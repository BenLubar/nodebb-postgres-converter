DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_name_history" h
 WHERE uc."_key" = 'user:' || h."uid" || ':usernames'
   AND uc."type" = 'zset'
   AND uc."unique_string" = h."name" || ':' || (EXTRACT(EPOCH FROM h."changed_at") * 1000)::BIGINT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM h."changed_at") * 1000)::NUMERIC;
