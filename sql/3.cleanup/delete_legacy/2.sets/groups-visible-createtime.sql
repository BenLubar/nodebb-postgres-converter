DELETE FROM "objects_legacy"
 WHERE "key0" = 'groups'
   AND "key1" = ARRAY['visible', 'createtime'];
