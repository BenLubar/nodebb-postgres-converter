UPDATE "objects_legacy"
   SET "data" = "data" - 'nextChatRoomId'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
