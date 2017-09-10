DELETE FROM "objects_legacy" p
 USING "objects_legacy" i
 WHERE i."key0" = 'posts'
   AND i."key1" = ARRAY['pid']
   AND p."key0" = 'post'
   AND p."key1" = ARRAY[i."value"];

DELETE FROM "objects_legacy" p
 USING "objects_legacy" i
 WHERE i."key0" = 'posts'
   AND i."key1" = ARRAY['pid']
   AND p."key0" = 'pid'
   AND p."key1" = ARRAY[i."value", 'replies'];
