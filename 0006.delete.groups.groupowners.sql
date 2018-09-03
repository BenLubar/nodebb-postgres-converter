DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" = 'group:' || g."name" || ':owners'
   AND uc."type" = 'set'
   AND uc."unique_string" = gm."uid"::TEXT
   AND gm."type" = 'owner';
