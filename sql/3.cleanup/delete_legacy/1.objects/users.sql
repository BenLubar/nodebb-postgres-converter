DELETE FROM "objects_legacy" u
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND u."key0" = 'user'
   AND (u."key1" = ARRAY[i."score"::text]
    OR  u."key1" = ARRAY[i."score"::text, 'settings']);

DELETE FROM "objects_legacy" u
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND u."key0" = 'uid'
   AND (u."key1" = ARRAY[i."score"::text, 'posts']
    OR  u."key1" = ARRAY[i."score"::text, 'topics']
    OR  u."key1" = ARRAY[i."score"::text, 'flagged_by']);
