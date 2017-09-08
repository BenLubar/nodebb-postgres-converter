DELETE FROM "objects_legacy" i
 USING "objects_legacy" r
 WHERE r."key0" = 'ip'
   AND r."key1" = ARRAY['recent']
   AND i."key0" = 'ip'
   AND i."key1" = string_to_array(r."value", ':') || ARRAY['uid'];

DELETE FROM "objects_legacy" u
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND u."key0" = 'user'
   AND u."key1" = ARRAY[i."score"::text, 'ip'];
