DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_followers" uf
 WHERE uc."_key" = 'followers:' || uf."uid"
   AND uc."type" = 'zset'
   AND uc."unique_string" = uf."follower_id"::TEXT
   AND uc."value_numeric" >= (EXTRACT(EPOCH FROM uf."followed_at") * 1000)::NUMERIC;
