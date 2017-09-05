DELETE FROM "objects_legacy" c
 USING "objects_legacy" i
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND c."key0" = 'category'
   AND c."key1" = ARRAY[i."value"];
