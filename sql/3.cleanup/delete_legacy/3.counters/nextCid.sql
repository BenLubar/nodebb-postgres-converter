UPDATE "objects_legacy"
   SET "data" = "data" - 'nextCid'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
