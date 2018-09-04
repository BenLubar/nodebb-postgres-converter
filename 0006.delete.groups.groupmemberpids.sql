DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 INNER JOIN "classify"."group_members" gm
         ON gm."uid" = p."uid"
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" = 'group:' || g."name" || ':member:pids'
   AND uc."type" = 'zset'
   AND uc."unique_string" = p."pid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM p."timestamp") * 1000)::NUMERIC;
