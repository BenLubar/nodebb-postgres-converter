DELETE FROM "objects_legacy" n
 USING "objects_legacy" i
 WHERE i."key0" = 'flags'
   AND i."key1" = ARRAY['datetime']
   AND n."key0" = 'flag'
   AND n."key1" = ARRAY[i."value", 'notes'];
