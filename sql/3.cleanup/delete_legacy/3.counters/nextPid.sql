UPDATE "objects_legacy"
   SET "data" = "data" - 'nextPid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
