DELETE FROM "objects_legacy" t
 USING "objects_legacy" i
 WHERE i."key0" = 'tags'
   AND i."key1" = ARRAY['topic', 'count']
   AND t."key0" = 'tag'
   AND t."key1" = ARRAY[i."value", 'topics'];
