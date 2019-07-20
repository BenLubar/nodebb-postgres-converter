-- manually-maintained... views?
DELETE FROM "classify"."unclassified"
 WHERE "_key" IN ('analytics:pageviews:month', 'analytics:pageviews:month:bot', 'analytics:pageviews:month:guest', 'analytics:pageviews:month:registered')
   AND "type" = 'zset';
