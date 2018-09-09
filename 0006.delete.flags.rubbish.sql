DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'post:[0-9]+'
   AND uc."type" = 'hash'
   AND uc."unique_string" IN ('flag:assignee', 'flag:history', 'flag:notes', 'flag:state', 'flags');

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'pid:[0-9]+:flag:(uids|uid:reason)|posts:(flagged|flags:count)|uid:[0-9]+:flag:pids|users:flags'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'uid:[0-9]+:flagged_by'
   AND uc."type" = 'set';
