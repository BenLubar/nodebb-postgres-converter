DELETE FROM "objects_legacy" c
 USING "objects_legacy" i
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND c."key0" = 'category'
   AND c."key1" = ARRAY[i."value"];

DELETE FROM "objects_legacy" c
 USING "objects_legacy" i
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND c."key0" = 'cid'
   AND (c."key1" = ARRAY[i."value", 'tids']
    OR  c."key1" = ARRAY[i."value", 'tids', 'posts']
    OR  c."key1" = ARRAY[i."value", 'children']
    OR  c."key1" = ARRAY[i."value", 'pids']
    OR  c."key1" = ARRAY[i."value", 'recent_tids']);

DELETE FROM "objects_legacy" c
 USING "objects_legacy" i
 CROSS JOIN "objects_legacy" u
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND u."key0" = 'username'
   AND u."key1" = ARRAY['uid']
   AND c."key0" = 'cid'
   AND c."key1" = ARRAY[i."value", 'uid', u."score"::text, 'tids'];
