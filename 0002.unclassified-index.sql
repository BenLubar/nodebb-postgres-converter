ALTER TABLE "classify"."unclassified_hash"
	ADD PRIMARY KEY ("_key", "unique_string"),
	CLUSTER ON "unclassified_hash_pkey";

ALTER TABLE "classify"."unclassified_zset"
	ADD PRIMARY KEY ("_key", "unique_string"),
	CLUSTER ON "unclassified_zset_pkey";

ALTER TABLE "classify"."unclassified_set"
	ADD PRIMARY KEY ("_key", "unique_string"),
	CLUSTER ON "unclassified_set_pkey";

ALTER TABLE "classify"."unclassified_list"
	ADD PRIMARY KEY ("_key", "unique_index"),
	CLUSTER ON "unclassified_list_pkey";

ALTER TABLE "classify"."unclassified_string"
	ADD PRIMARY KEY ("_key"),
	CLUSTER ON "unclassified_string_pkey";

ANALYZE "classify"."unclassified_hash";
ANALYZE "classify"."unclassified_zset";
ANALYZE "classify"."unclassified_set";
ANALYZE "classify"."unclassified_list";
ANALYZE "classify"."unclassified_string";
