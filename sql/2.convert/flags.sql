CREATE TYPE flag_state AS ENUM ('open', 'wip', 'resolved', 'rejected');

CREATE TABLE "flags" (
	"flagId" bigserial NOT NULL,
	"uid" bigint NOT NULL,
	"state" flag_state NOT NULL DEFAULT 'open',
	"assignee" bigint DEFAULT NULL,
	"datetime" timestamptz NOT NULL DEFAULT NOW(),
	"description" text NOT NULL,
	"targetPid" bigint DEFAULT NULL,
	"targetUid" bigint DEFAULT NULL,
	"data" jsonb NOT NULL DEFAULT '{}',

	CHECK(CASE WHEN "targetPid" IS NULL THEN 0 ELSE 1 END
            + CASE WHEN "targetUid" IS NULL THEN 0 ELSE 1 END
            = 1)
) WITH (autovacuum_enabled = false);

INSERT INTO "flags" SELECT
       (f."data"->>'flagId')::bigint "flagId",
       (f."data"->>'uid')::bigint "uid",
       (f."data"->>'state')::flag_state "state",
       NULLIF(NULLIF(NULLIF(f."data"->>'assignee', ''), '0'), 'undefined')::bigint "assignee",
       to_timestamp((f."data"->>'datetime')::double precision / 1000) "datetime",
       f."data"->>'description' "description",
       CASE WHEN (f."data"->>'type') = 'post' THEN (f."data"->>'targetId')::bigint ELSE NULL END "targetPid",
       CASE WHEN (f."data"->>'type') = 'user' THEN (f."data"->>'targetId')::bigint ELSE NULL END "targetUid",
       f."data" - 'flagId' - 'uid' - 'state' - 'assignee' - 'datetime' - 'description' - 'type' - 'targetId' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" f
    ON f."key0" = 'flag'
   AND f."key1" = ARRAY[i."value"]
 WHERE i."key0" = 'flags'
   AND i."key1" = ARRAY['datetime'];

SELECT setval('"flags_flagId_seq"', ("data"->>'nextFlagId')::bigint)
  FROM "objects_legacy"
 WHERE "key0" = 'global'
   AND "key1" = ARRAY[]::text[];

ALTER TABLE "flags" ADD PRIMARY KEY ("flagId");

CREATE INDEX "idx__flags__uid" ON "flags"("uid");

CREATE INDEX "idx__flags__state" ON "flags"("state");

CREATE INDEX "idx__flags__assignee" ON "flags"("assignee");

CREATE INDEX "idx__flags__datetime" ON "flags"("datetime");

CREATE INDEX "idx__flags__targetPid" ON "flags"("targetPid");

CREATE INDEX "idx__flags__targetUid" ON "flags"("targetUid");

ALTER TABLE "flags"
      CLUSTER ON "flags_pkey";
