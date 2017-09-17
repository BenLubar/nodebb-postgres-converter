DELETE FROM "objects_legacy"
 WHERE "key0" = 'userslug'
   AND "key1" = ARRAY['uid'];
