DELETE FROM "objects_legacy" e
 USING "objects_legacy" i
 WHERE i."key0" = 'events'
   AND i."key1" = ARRAY['time']
   AND e."key0" = 'event'
   AND e."key1" = ARRAY[i."value"];
