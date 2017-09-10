DELETE FROM "objects_legacy"
 WHERE "key0" = 'analytics'
   AND "key1" = ARRAY['errors', '404'];
