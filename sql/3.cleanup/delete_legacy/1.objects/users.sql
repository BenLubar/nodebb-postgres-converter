DELETE FROM "objects_legacy" u
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND u."key0" = 'user'
   AND (u."key1" = ARRAY[i."score"::text]
    OR  u."key1" = ARRAY[i."score"::text, 'settings']);
