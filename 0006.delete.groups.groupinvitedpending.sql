DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" IN ('group:' || g."name" || ':invited', 'group:' || g."name" || ':pending')
   AND uc."type" = 'set'
   AND uc."unique_string" = gm."uid"::TEXT;
