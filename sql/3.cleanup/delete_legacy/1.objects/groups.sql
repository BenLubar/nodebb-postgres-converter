DELETE FROM "objects_legacy" g
 USING "objects_legacy" i
 WHERE i."key0" = 'groups'
   AND i."key1" = ARRAY['createtime']
   AND g."key0" = 'group'
   AND g."key1" = ARRAY[i."value"];
