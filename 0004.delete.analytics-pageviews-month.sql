-- manually-maintained... view?
DELETE FROM "classify"."unclassified"
 WHERE "_key" = 'analytics:pageviews:month'
   AND "type" = 'zset';
