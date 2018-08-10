DROP SCHEMA IF EXISTS "classify" CASCADE;

CREATE SCHEMA "classify";

CREATE UNLOGGED TABLE "classify"."unclassified" (
	"_key" TEXT NOT NULL COLLATE "C",
	"type" LEGACY_OBJECT_TYPE NOT NULL,
	"unique_index" INT,
	"unique_string" TEXT COLLATE "C",
	"value_numeric" NUMERIC,
	"value_string" TEXT COLLATE "C"
)
PARTITION BY LIST ("type")
WITHOUT OIDS;

CREATE UNLOGGED TABLE "classify"."unclassified_hash"
PARTITION OF "classify"."unclassified" (
	"unique_index" WITH OPTIONS CHECK ("unique_index" IS NULL),
	"unique_string" WITH OPTIONS NOT NULL,
	"value_numeric" WITH OPTIONS CHECK ("value_numeric" IS NULL),
	"value_string" WITH OPTIONS NOT NULL,
	PRIMARY KEY ("_key", "unique_string")
) FOR VALUES IN ('hash')
WITHOUT OIDS;

ALTER TABLE "classify"."unclassified_hash" CLUSTER ON "unclassified_hash_pkey";

CREATE UNLOGGED TABLE "classify"."unclassified_zset"
PARTITION OF "classify"."unclassified" (
	"unique_index" WITH OPTIONS CHECK ("unique_index" IS NULL),
	"unique_string" WITH OPTIONS NOT NULL,
	"value_numeric" WITH OPTIONS NOT NULL,
	"value_string" WITH OPTIONS CHECK ("value_string" IS NULL),
	PRIMARY KEY ("_key", "unique_string")
) FOR VALUES IN ('zset')
WITHOUT OIDS;

ALTER TABLE "classify"."unclassified_zset" CLUSTER ON "unclassified_zset_pkey";

CREATE UNLOGGED TABLE "classify"."unclassified_set"
PARTITION OF "classify"."unclassified" (
	"unique_index" WITH OPTIONS CHECK ("unique_index" IS NULL),
	"unique_string" WITH OPTIONS NOT NULL,
	"value_numeric" WITH OPTIONS CHECK ("value_numeric" IS NULL),
	"value_string" WITH OPTIONS CHECK ("value_string" IS NULL),
	PRIMARY KEY ("_key", "unique_string")
) FOR VALUES IN ('set')
WITHOUT OIDS;

ALTER TABLE "classify"."unclassified_set" CLUSTER ON "unclassified_set_pkey";

CREATE UNLOGGED TABLE "classify"."unclassified_list"
PARTITION OF "classify"."unclassified" (
	"unique_index" WITH OPTIONS NOT NULL,
	"unique_string" WITH OPTIONS CHECK ("unique_string" IS NULL),
	"value_numeric" WITH OPTIONS CHECK ("value_numeric" IS NULL),
	"value_string" WITH OPTIONS NOT NULL,
	PRIMARY KEY ("_key", "unique_index")
) FOR VALUES IN ('list')
WITHOUT OIDS;

ALTER TABLE "classify"."unclassified_list" CLUSTER ON "unclassified_list_pkey";

CREATE UNLOGGED TABLE "classify"."unclassified_string"
PARTITION OF "classify"."unclassified" (
	"unique_index" WITH OPTIONS CHECK ("unique_index" IS NULL),
	"unique_string" WITH OPTIONS CHECK ("unique_string" IS NULL),
	"value_numeric" WITH OPTIONS CHECK ("value_numeric" IS NULL),
	"value_string" WITH OPTIONS NOT NULL,
	PRIMARY KEY ("_key")
) FOR VALUES IN ('string')
WITHOUT OIDS;

ALTER TABLE "classify"."unclassified_string" CLUSTER ON "unclassified_string_pkey";
