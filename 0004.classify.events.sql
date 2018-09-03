CREATE TEMPORARY TABLE "event_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('event:') + 1)::BIGINT "eid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'event:[0-9]+'
   AND "type" = 'hash';

CREATE TABLE "classify"."events" (
	"eid" BIGSERIAL NOT NULL,
	"type" TEXT COLLATE "C" NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"ip" INET NOT NULL,
	"uid" BIGINT NOT NULL,
	"data" JSONB NOT NULL DEFAULT '{}'
) WITHOUT OIDS;

INSERT INTO "classify"."events"
SELECT eid."unique_string"::BIGINT,
       type."value",
       TO_TIMESTAMP(eid."value_numeric" / 1000),
       SPLIT_PART(ip."value", ',', 1)::INET,
       uid."value"::BIGINT,
       COALESCE((SELECT jsonb_object_agg(data."field", data."value")
                   FROM "event_data" data
                  WHERE data."eid" = eid."unique_string"::BIGINT
                    AND data."field" NOT IN ('eid', 'type', 'timestamp', 'ip', 'uid')), '{}')
  FROM "classify"."unclassified" eid
 INNER JOIN "event_data" type
         ON type."eid" = eid."unique_string"::BIGINT
        AND type."field" = 'type'
 INNER JOIN "event_data" ip
         ON ip."eid" = eid."unique_string"::BIGINT
        AND ip."field" = 'ip'
 INNER JOIN "event_data" uid
         ON uid."eid" = eid."unique_string"::BIGINT
        AND uid."field" = 'uid'
 WHERE eid."_key" = 'events:time'
   AND eid."type" = 'zset';

\o /dev/null
SELECT setval('classify.events_eid_seq', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextEid')::BIGINT);
\o

ALTER TABLE "classify"."events"
	ADD PRIMARY KEY ("eid"),
	CLUSTER ON "events_pkey";
CREATE INDEX ON "classify"."events"("type");
CREATE INDEX ON "classify"."events"("timestamp");
CREATE INDEX ON "classify"."events"("ip");
CREATE INDEX ON "classify"."events"("uid");
