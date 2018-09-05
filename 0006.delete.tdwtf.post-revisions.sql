DELETE FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'pid:[0-9]+:postRevisions'
   AND "type" = 'hash';

DELETE FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'pid:[0-9]+:revisions'
   AND "type" = 'zset';
