INSERT INTO "classify"."unclassified" ("_key", "type", "unique_string", "value_string")
SELECT h."_key", h."type", d."field", h."data"->>d."field"
  FROM "legacy_hash" h
 CROSS JOIN jsonb_object_keys(jsonb_strip_nulls(h."data")) d("field");

ANALYZE VERBOSE "classify"."unclassified_hash";
