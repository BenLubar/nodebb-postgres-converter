INSERT INTO "classify"."unclassified" ("_key", "type", "unique_index", "value_string")
SELECT l."_key", l."type", v."index", v."value"
  FROM "legacy_list" l
 CROSS JOIN UNNEST(l."array") WITH ORDINALITY v("value", "index");

CLUSTER VERBOSE "classify"."unclassified_list";
ANALYZE VERBOSE "classify"."unclassified_list";
