DELETE FROM "objects_legacy" i
 USING "objects_legacy" r
 WHERE r."key0" = 'ip'
   AND r."key1" = ARRAY['recent']
   AND i."key0" = 'ip'
   AND i."key1" = string_to_array(r."value", ':') || ARRAY['uid'];
