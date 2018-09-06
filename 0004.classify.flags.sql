CREATE TYPE "classify".FLAG_STATE AS ENUM ('open', 'wip', 'resolved', 'rejected');

CREATE TABLE "classify"."flags" (
	"flagId" BIGSERIAL NOT NULL,
	"reporter" BIGINT NOT NULL,
	"datetime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"description" TEXT COLLATE "C" NOT NULL,
	"state" "classify".FLAG_STATE NOT NULL DEFAULT 'open',
	"assignee" BIGINT,
	"targetPid" BIGINT,
	"targetUid" BIGINT,
	CHECK (
		CASE WHEN "targetPid" IS NULL THEN 0 ELSE 1 END +
		CASE WHEN "targetUid" IS NULL THEN 0 ELSE 1 END = 1
	)
) WITHOUT OIDS;

INSERT INTO "classify"."flags"
SELECT flagId."value_string"::BIGINT,
       reporter."value_string"::BIGINT,
       TO_TIMESTAMP(datetime."value_string"::NUMERIC / 1000),
       description."value_string",
       state."value_string"::"classify".FLAG_STATE,
       NULLIF(assignee."value_string", '')::BIGINT,
       CASE WHEN type_."value_string" = 'post' THEN targetId."value_string"::BIGINT ELSE NULL END,
       CASE WHEN type_."value_string" = 'user' THEN targetId."value_string"::BIGINT ELSE NULL END
  FROM "classify"."unclassified" flagId
 INNER JOIN "classify"."unclassified" reporter
         ON reporter."_key" = flagId."_key"
        AND reporter."type" = 'hash'
        AND reporter."unique_string" = 'uid'
 INNER JOIN "classify"."unclassified" datetime
         ON datetime."_key" = flagId."_key"
        AND datetime."type" = 'hash'
        AND datetime."unique_string" = 'datetime'
 INNER JOIN "classify"."unclassified" description
         ON description."_key" = flagId."_key"
        AND description."type" = 'hash'
        AND description."unique_string" = 'description'
 INNER JOIN "classify"."unclassified" state
         ON state."_key" = flagId."_key"
        AND state."type" = 'hash'
        AND state."unique_string" = 'state'
 INNER JOIN "classify"."unclassified" assignee
         ON assignee."_key" = flagId."_key"
        AND assignee."type" = 'hash'
        AND assignee."unique_string" = 'assignee'
 INNER JOIN "classify"."unclassified" type_
         ON type_."_key" = flagId."_key"
        AND type_."type" = 'hash'
        AND type_."unique_string" = 'type'
 INNER JOIN "classify"."unclassified" targetId
         ON targetId."_key" = flagId."_key"
        AND targetId."type" = 'hash'
        AND targetId."unique_string" = 'targetId'
 WHERE flagId."_key" SIMILAR TO 'flag:[0-9]+'
   AND flagId."type" = 'hash'
   AND flagId."unique_string" = 'flagId'
   AND flagId."value_string" = SPLIT_PART(flagId."_key", ':', 2);

\o /dev/null
SELECT setval('classify."flags_flagId_seq"', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextFlagId')::BIGINT);
\o

ALTER TABLE "classify"."flags"
	ADD PRIMARY KEY ("flagId"),
	CLUSTER ON "flags_pkey";
CREATE INDEX ON "classify"."flags"("reporter");
CREATE INDEX ON "classify"."flags"("datetime");
CREATE INDEX ON "classify"."flags"("state");
CREATE INDEX ON "classify"."flags"("assignee");
CREATE INDEX ON "classify"."flags"("targetPid");
CREATE INDEX ON "classify"."flags"("targetUid");

CREATE TABLE "classify"."flag_history" (
	"history_id" BIGSERIAL NOT NULL,
	"flagId" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"datetime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"state" "classify".FLAG_STATE,
	"assignee" BIGINT,
	"unset_assignee" BOOLEAN NOT NULL DEFAULT FALSE,
	CHECK("assignee" IS NULL OR NOT "unset_assignee"),
	"notes_updated" BOOLEAN NOT NULL DEFAULT FALSE
) WITHOUT OIDS;

INSERT INTO "classify"."flag_history"
SELECT NEXTVAL('classify.flag_history_history_id_seq'::REGCLASS),
       SPLIT_PART("_key", ':', 2)::BIGINT,
       ("unique_string"::JSONB->>0)::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       ("unique_string"::JSONB->1->>'state')::"classify".FLAG_STATE,
       NULLIF("unique_string"::JSONB->1->>'assignee', '')::BIGINT,
       COALESCE(("unique_string"::JSONB->1->>'assignee') = '', FALSE),
       ("unique_string"::JSONB->1) ? 'notes'
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'flag:[0-9]+:history'
   AND "type" = 'zset'
   AND "value_numeric" = ("unique_string"::JSONB->>2)::NUMERIC
 ORDER BY "value_numeric" ASC;

ALTER TABLE "classify"."flag_history"
	ADD PRIMARY KEY ("history_id"),
	CLUSTER ON "flag_history_pkey";
CREATE INDEX ON "classify"."flag_history"("flagId", "datetime");

CREATE TABLE "classify"."flag_notes" (
	"note_id" BIGSERIAL NOT NULL,
	"flagId" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"datetime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"note" TEXT COLLATE "C" NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."flag_notes"
SELECT NEXTVAL('classify.flag_notes_note_id_seq'::REGCLASS),
       SPLIT_PART("_key", ':', 2)::BIGINT,
       ("unique_string"::JSONB->>0)::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000),
       "unique_string"::JSONB->>1
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'flag:[0-9]+:notes'
   AND "type" = 'zset'
 ORDER BY "value_numeric" ASC;

ALTER TABLE "classify"."flag_notes"
	ADD PRIMARY KEY ("note_id"),
	CLUSTER ON "flag_notes_pkey";
CREATE INDEX ON "classify"."flag_notes"("flagId", "datetime");
