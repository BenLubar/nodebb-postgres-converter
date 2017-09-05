DELETE FROM "objects_legacy" t
 USING "objects_legacy" i
 WHERE i."key0" = 'topics'
   AND i."key1" = ARRAY['tid']
   AND t."key0" = 'topic'
   AND t."key1" = ARRAY[i."value"];
