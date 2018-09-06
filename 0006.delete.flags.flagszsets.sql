DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byAssignee:([0-9]+|undefined)?'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byCid:[0-9]+'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byPid:[0-9]+'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byReporter:[0-9]+'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byState:(open|wip|resolved|rejected)'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byTargetUid:[0-9]+'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" SIMILAR TO 'flags:byType:(post|user)'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = 'flags:datetime'
   AND uc."type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = 'flags:hash'
   AND uc."type" = 'zset';
