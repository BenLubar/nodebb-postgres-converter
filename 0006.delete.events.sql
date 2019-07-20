-- delete all events

DELETE FROM "classify"."unclassified" uc1
 USING "classify"."unclassified" uc2
 WHERE uc1."_key" = 'event:' || uc2."unique_string"
   AND uc1."type" = 'hash'
   AND uc2."_key" = 'events:time'
   AND uc2."type" = 'zset';

DELETE FROM "classify"."unclassified"
 WHERE "_key" = 'events:time'
   AND "type" = 'zset';

DELETE FROM "classify"."unclassified" uc
 USING "events" e
 WHERE uc."_key" = 'events:time:' || e."type"
   AND uc."type" = 'zset';
