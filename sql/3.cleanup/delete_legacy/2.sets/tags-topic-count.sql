DELETE FROM "objects_legacy"
 WHERE "key0" = 'tags'
   AND "key1" = ARRAY['topic', 'count'];
