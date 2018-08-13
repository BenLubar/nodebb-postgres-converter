INSERT INTO "classify"."unclassified" ("_key", "type", "value_string")
SELECT s."_key", s."type", s."data"
  FROM "legacy_string" s;

CLUSTER VERBOSE "classify"."unclassified_string";
ANALYZE VERBOSE "classify"."unclassified_string";
