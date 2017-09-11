DELETE FROM "objects_legacy" n
 USING "objects_legacy" i
 WHERE i."key0" = 'notifications'
   AND i."key1" = ARRAY[]::text[]
   AND n."key0" = 'notifications'
   AND n."key1" = string_to_array(i."value", ':');
