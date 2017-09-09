DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'flags'
   AND i."key1" = ARRAY['datetime']
   AND f."key0" = 'flag'
   AND f."key1" = ARRAY[i."value"];

DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND f."key0" = 'flags'
   AND f."key1" = ARRAY['byAssignee', i."score"::text];

DELETE FROM "objects_legacy" f
 WHERE f."key0" = 'flags'
   AND (f."key1" = ARRAY['byAssignee', '']
    OR  f."key1" = ARRAY['byAssignee', 'undefined']);

DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND f."key0" = 'flags'
   AND f."key1" = ARRAY['byCid', i."value"];

DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'posts'
   AND i."key1" = ARRAY['pid']
   AND f."key0" = 'flags'
   AND f."key1" = ARRAY['byPid', i."value"];

DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND f."key0" = 'flags'
   AND f."key1" = ARRAY['byReporter', i."score"::text];

DELETE FROM "objects_legacy" f
 WHERE f."key0" = 'flags'
   AND (f."key1" = ARRAY['byState', 'open']
    OR  f."key1" = ARRAY['byState', 'wip']
    OR  f."key1" = ARRAY['byState', 'resolved']
    OR  f."key1" = ARRAY['byState', 'rejected']);

DELETE FROM "objects_legacy" f
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND f."key0" = 'flags'
   AND f."key1" = ARRAY['byTargetUid', i."score"::text];

DELETE FROM "objects_legacy" f
 WHERE f."key0" = 'flags'
   AND (f."key1" = ARRAY['byType', 'post']
    OR  f."key1" = ARRAY['byType', 'user']);
