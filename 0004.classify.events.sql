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
	"targetUid" BIGINT,
	"pid" BIGINT,
	"tid" BIGINT,
	"oldValue" TEXT COLLATE "C",
	"newValue" TEXT COLLATE "C",
	"data" JSONB NOT NULL DEFAULT '{}'
) WITHOUT OIDS;

INSERT INTO "classify"."events"
SELECT eid."unique_string"::BIGINT,
       type."value",
       TO_TIMESTAMP(eid."value_numeric" / 1000),
       SPLIT_PART(ip."value", ',', 1)::INET,
       uid."value"::BIGINT,
       targetUid."value"::BIGINT,
       pid."value"::BIGINT,
       tid."value"::BIGINT,
       oldValue."value",
       newValue."value",
       COALESCE((SELECT jsonb_object_agg(data."field", data."value")
                   FROM "event_data" data
                  WHERE data."eid" = eid."unique_string"::BIGINT
                    AND data."field" NOT IN ('eid', 'type', 'timestamp', 'ip', 'uid', 'targetUid', 'pid', 'tid')
                    AND data."field" NOT SIMILAR TO '(old|new)(Email|Title|Username)'), '{}')
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
  LEFT JOIN "event_data" targetUid
         ON targetUid."eid" = eid."unique_string"::BIGINT
        AND targetUid."field" = 'targetUid'
  LEFT JOIN "event_data" pid
         ON pid."eid" = eid."unique_string"::BIGINT
        AND pid."field" = 'pid'
  LEFT JOIN "event_data" tid
         ON tid."eid" = eid."unique_string"::BIGINT
        AND tid."field" = 'tid'
  LEFT JOIN "event_data" oldValue
         ON oldValue."eid" = eid."unique_string"::BIGINT
        AND oldValue."field" IN ('oldEmail', 'oldTitle', 'oldUsername')
  LEFT JOIN "event_data" newValue
         ON newValue."eid" = eid."unique_string"::BIGINT
        AND newValue."field" IN ('newEmail', 'newTitle', 'newUsername')
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
CREATE INDEX ON "classify"."events"("targetUid");
CREATE INDEX ON "classify"."events"("pid");
CREATE INDEX ON "classify"."events"("tid");
