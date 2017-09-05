UPDATE "objects_legacy"
   SET "data" = "data" - 'nextMid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
