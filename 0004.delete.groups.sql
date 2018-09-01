DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'name'
   AND uc."value_string" = g."name";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'slug'
   AND uc."value_string" = g."slug";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'createtime'
   AND uc."value_string" = (EXTRACT(EPOCH FROM g."createtime") * 1000)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'description'
   AND uc."value_string" = g."description";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'memberCount'
   AND uc."value_string" = g."memberCount"::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'private'
   AND uc."value_string" = CASE WHEN g."private" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'system'
   AND uc."value_string" = CASE WHEN g."system" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'hidden'
   AND uc."value_string" = CASE WHEN g."hidden" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'disableJoinRequests'
   AND uc."value_string" = CASE WHEN g."disableJoinRequests" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'deleted'
   AND uc."value_string" = CASE WHEN g."deleted" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'userTitleEnabled'
   AND uc."value_string" = CASE WHEN g."userTitleEnabled" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'userTitle'
   AND uc."value_string" = COALESCE(g."userTitle", '');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'labelColor'
   AND uc."value_string" = COALESCE(g."labelColor", '');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'icon'
   AND uc."value_string" = COALESCE(g."icon", '');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'cover:thumb:url'
   AND uc."value_string" = COALESCE(g."cover:thumb:url", '');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'group:' || g."name"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'cover:position';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groupslug:groupname'
   AND uc."type" = 'hash'
   AND uc."unique_string" = g."slug"
   AND uc."value_string" = g."name";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:createtime'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM g."createtime") * 1000)::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:createtime'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM g."createtime") * 1000)::NUMERIC
   AND NOT g."hidden";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:memberCount'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = g."memberCount"
   AND NOT g."hidden";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."groups" g
 WHERE uc."_key" = 'groups:visible:name'
   AND uc."type" = 'zset'
   AND uc."unique_string" = g."name"
   AND uc."value_numeric" = 0
   AND NOT g."hidden";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" = 'group:' || g."name" || ':members'
   AND uc."type" = 'zset'
   AND uc."unique_string" = gm."uid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM gm."joined_at") * 1000)::NUMERIC
   AND gm."type" IN ('member', 'owner');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" = 'group:' || g."name" || ':owners'
   AND uc."type" = 'set'
   AND uc."unique_string" = gm."uid"::TEXT
   AND gm."type" = 'owner';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."group_members" gm
 INNER JOIN "classify"."groups" g
         ON g."gid" = gm."gid"
 WHERE uc."_key" IN ('group:' || g."name" || ':invited', 'group:' || g."name" || ':pending')
   AND uc."type" = 'set'
   AND uc."unique_string" = gm."uid"::TEXT;
