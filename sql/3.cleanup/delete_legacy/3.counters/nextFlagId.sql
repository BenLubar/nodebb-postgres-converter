UPDATE "objects_legacy"
   SET "data" = "data" - 'nextFlagId'
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];
