UPDATE "objects_legacy"
   SET "data" = "data" - 'nextTid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
