CREATE TABLE "notifications" (
	"nid" text NOT NULL,
	"type" text NOT NULL,
	"path" text,
	"datetime" timestamptz NOT NULL DEFAULT NOW(),
	"mergeId" text DEFAULT NULL,
	"from" bigint DEFAULT NULL,
	"tid" bigint DEFAULT NULL,
	"pid" bigint DEFAULT NULL,
	"image" text DEFAULT NULL,
	"bodyShort" text NOT NULL,
	"bodyLong" text NOT NULL,
	"topicTitle" text DEFAULT NULL,
	"importance" int DEFAULT NULL,
	"data" jsonb NOT NULL DEFAULT '{}'
) WITH (autovacuum_enabled = false);

INSERT INTO "notifications" SELECT
       i."value" "nid",
       COALESCE(n."data"->>'type', '') "type",
       n."data"->> 'path' "path",
       to_timestamp((n."data"->>'datetime')::double precision / 1000) "datetime",
       NULLIF(n."data"->>'mergeId', '') "mergeId",
       NULLIF(NULLIF(n."data"->>'from', ''), '0')::bigint "from",
       NULLIF(NULLIF(n."data"->>'tid', ''), '0')::bigint "tid",
       NULLIF(NULLIF(n."data"->>'pid', ''), '0')::bigint "pid",
       NULLIF(n."data"->>'image', '') "image",
       COALESCE(n."data"->>'bodyShort', '') "bodyShort",
       COALESCE(n."data"->>'bodyLong', '') "bodyLong",
       CASE WHEN n."data" ? 'topicTitle' THEN n."data"->>'topicTitle' ELSE NULL END "topicTitle",
       NULLIF(n."data"->>'importance', '')::int "importance",
       n."data" - 'nid' - 'type' - 'path' - 'datetime' - 'mergeId' - 'from' - 'tid' - 'pid' - 'image' - 'bodyShort' - 'bodyLong' - 'topicTitle' - 'importance' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" n
    ON n."key0" = 'notifications'
   AND n."key1" = string_to_array(i."value", ':')
 WHERE i."key0" = 'notifications'
   AND i."key1" = ARRAY[]::text[];

ALTER TABLE "notifications" ADD PRIMARY KEY ("nid");

CREATE INDEX "idx__notifications__type" ON "notifications"("type");

CREATE INDEX "idx__notifications__datetime" ON "notifications"("datetime");

CREATE INDEX "idx__notifications__mergeId" ON "notifications"("mergeId");

CREATE INDEX "idx__notifications__from" ON "notifications"("from");

CREATE INDEX "idx__notifications__tid" ON "notifications"("tid");

CREATE INDEX "idx__notifications__pid" ON "notifications"("pid");

CREATE INDEX "idx__notifications__importance" ON "notifications"("importance");

ALTER TABLE "notifications"
      CLUSTER ON "notifications_pkey";
