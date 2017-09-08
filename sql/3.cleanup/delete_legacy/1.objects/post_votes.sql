DELETE FROM "objects_legacy" v
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND v."key0" = 'uid'
   AND (v."key1" = ARRAY[i."score"::text, 'upvote']
    OR  v."key1" = ARRAY[i."score"::text, 'downvote']);

DELETE FROM "objects_legacy" v
 USING "objects_legacy" i
 WHERE i."key0" = 'posts'
   AND i."key1" = ARRAY['pid']
   AND v."key0" = 'pid'
   AND (v."key1" = ARRAY[i."value", 'upvote']
    OR  v."key1" = ARRAY[i."value", 'downvote']);
