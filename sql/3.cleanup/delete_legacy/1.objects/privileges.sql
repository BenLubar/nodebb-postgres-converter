DELETE FROM "objects_legacy" p
 USING "objects_legacy" i
 CROSS JOIN UNNEST(enum_range(NULL::category_privilege)) e(e)
 WHERE i."key0" = 'categories'
   AND i."key1" = ARRAY['cid']
   AND p."key0" = 'group'
   AND (p."key1" = ARRAY['cid', i."value", 'privileges'] || string_to_array(e.e::text, ':')
    OR  p."key1" = ARRAY['cid', i."value", 'privileges'] || string_to_array(e.e::text, ':') || ARRAY['members']
    OR  p."key1" = ARRAY['cid', i."value", 'privileges', 'groups'] || string_to_array(e.e::text, ':')
    OR  p."key1" = ARRAY['cid', i."value", 'privileges', 'groups'] || string_to_array(e.e::text, ':') || ARRAY['members']);
