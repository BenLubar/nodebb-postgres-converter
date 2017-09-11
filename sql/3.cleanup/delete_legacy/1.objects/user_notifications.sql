DELETE FROM "objects_legacy" n
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND n."key0" = 'uid'
   AND (n."key1" = ARRAY[i."score"::text, 'notifications', 'unread']
    OR  n."key1" = ARRAY[i."score"::text, 'notifications', 'read']);
