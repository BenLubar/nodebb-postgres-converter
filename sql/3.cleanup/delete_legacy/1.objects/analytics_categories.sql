DELETE FROM "objects_legacy" a
 USING "objects_legacy" i
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND a."key0" = 'analytics'
   AND (a."key1" = ARRAY['pageviews', 'byCid', i."value"]
    OR  a."key1" = ARRAY['posts', 'byCid', i."value"]
    OR  a."key1" = ARRAY['topics', 'byCid', i."value"]);
