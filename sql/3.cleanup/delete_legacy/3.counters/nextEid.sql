UPDATE "objects_legacy"
   SET "data" = "data" - 'nextEid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
