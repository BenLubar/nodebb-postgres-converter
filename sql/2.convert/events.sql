CREATE TABLE "events" (
	"eid" bigserial NOT NULL,
	"type" text NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW(),
	"uid" bigint DEFAULT NULL,
	"ip" inet[] NOT NULL DEFAULT '{}',
	"data" jsonb NOT NULL DEFAULT '{}'
);


INSERT INTO "events" SELECT
       (i."value")::bigint "eid",
       e."data"->>'type' "type",
       to_timestamp(i."score"::double precision / 1000) "timestamp",
       NULLIF(NULLIF(e."data"->>'uid', ''), '0')::bigint "uid",
       COALESCE(string_to_array(NULLIF(e."data"->>'ip', ''), ', ')::inet[], '{}') "ip",
       e."data" - 'eid' - 'type' - 'timestamp' - 'uid' - 'ip' "data"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" e
    ON e."key0" = 'event'
   AND e."key1" = ARRAY[i."value"]
 WHERE i."key0" = 'events'
   AND i."key1" = ARRAY['time'];

DO $$
DECLARE
	"nextEid" bigint;
BEGIN
	SELECT "data"->>'nextEid' INTO "nextEid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "events_eid_seq" RESTART WITH ' || ("nextEid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "events" ADD PRIMARY KEY ("eid");

CREATE INDEX "idx__events__type" ON "events"("type");

CREATE INDEX "idx__events__timestamp" ON "events"("timestamp" DESC);

CREATE INDEX "idx__events__uid" ON "events"("uid");

CREATE INDEX "idx__events__ip" ON "events"("ip");

ALTER TABLE "events"
      CLUSTER ON "events_pkey";
