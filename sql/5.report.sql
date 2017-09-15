SELECT * FROM (
SELECT array_to_string("key0" || "key1", ':') "key",
       'value'::text "type",
       NULL::bigint "members"
  FROM "objects_legacy"
 WHERE "value" IS NOT NULL
   AND "score" IS NULL
 GROUP BY "key0", "key1"
 ORDER BY "key0" ASC, "key1" ASC) a
 UNION ALL SELECT * FROM (
SELECT array_to_string("key0" || "key1", ':') "key",
       'sorted set'::text "type",
       COUNT(*)::bigint "members"
  FROM "objects_legacy"
 WHERE "value" IS NOT NULL
   AND "score" IS NOT NULL
 GROUP BY "key0", "key1"
 ORDER BY "key0" ASC, "key1" ASC) a
 UNION ALL SELECT * FROM (
SELECT array_to_string("key0" || "key1", ':') "key",
       'hash'::text "type",
       NULL::bigint "members"
  FROM "objects_legacy"
 WHERE "value" IS NULL
   AND "score" IS NULL
   AND NOT ("data" ? 'members')
   AND NOT ("data" ? 'array')
 GROUP BY "key0", "key1"
 ORDER BY "key0" ASC, "key1" ASC) a
 UNION ALL SELECT * FROM (
SELECT array_to_string("key0" || "key1", ':') "key",
       'set'::text "type",
       SUM(jsonb_array_length("data"->'members')::bigint) "members"
  FROM "objects_legacy"
 WHERE "value" IS NULL
   AND "score" IS NULL
   AND ("data" ? 'members')
   AND NOT ("data" ? 'array')
 GROUP BY "key0", "key1"
 ORDER BY "key0" ASC, "key1" ASC) a
 UNION ALL SELECT * FROM (
SELECT array_to_string("key0" || "key1", ':') "key",
       'list'::text "type",
       SUM(jsonb_array_length("data"->'array')::bigint) "members"
  FROM "objects_legacy"
 WHERE "value" IS NULL
   AND "score" IS NULL
   AND NOT ("data" ? 'members')
   AND ("data" ? 'array')
 GROUP BY "key0", "key1"
 ORDER BY "key0" ASC, "key1" ASC) a;
