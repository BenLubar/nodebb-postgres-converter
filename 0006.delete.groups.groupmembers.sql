DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" = 'group:' || g."name" || ':members'
   AND uc."type" = 'zset'
   AND uc."unique_string" = gm."uid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM gm."joined_at") * 1000)::NUMERIC
   AND gm."type" IN ('member', 'owner');
