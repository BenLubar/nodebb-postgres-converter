UPDATE "objects_legacy"
   SET "data" = "data" - 'nextUid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
