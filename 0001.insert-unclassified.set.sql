INSERT INTO "classify"."unclassified" ("_key", "type", "unique_string")
SELECT s."_key", s."type", s."member"
  FROM "legacy_set" s;

CLUSTER VERBOSE "classify"."unclassified_set";
ANALYZE VERBOSE "classify"."unclassified_set";
