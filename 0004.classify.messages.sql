CREATE TEMPORARY TABLE "message_data" ON COMMIT DROP AS
SELECT SPLIT_PART("_key", ':', 2)::BIGINT "mid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'message:[0-9]+'
   AND "type" = 'hash';

INSERT INTO "message_data"
SELECT DISTINCT
       "unique_string"::BIGINT,
       'roomId',
       SPLIT_PART("_key", ':', 5)
  FROM "classify"."unclassified"
  LEFT JOIN "message_data"
         ON "mid" = "unique_string"::BIGINT
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:chat:room:[0-9]+:mids'
   AND "type" = 'zset'
   AND "mid" IS NULL;

ALTER TABLE "message_data"
	ADD PRIMARY KEY ("mid", "field"),
	CLUSTER ON "message_data_pkey";

ANALYZE "message_data";

CREATE TABLE "classify"."messages" (
	"mid" BIGSERIAL NOT NULL,
	"roomId" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"content" TEXT COLLATE "C" NOT NULL,
	"ip" INET
) WITHOUT OIDS;

INSERT INTO "classify"."messages"
SELECT fromuid."mid",
       roomId."value"::BIGINT,
       fromuid."value"::BIGINT,
       TO_TIMESTAMP(timestamp."value"::NUMERIC / 1000),
       content."value",
       SPLIT_PART(ip."value", ',', 1)::INET
  FROM "message_data" fromuid
 INNER JOIN "message_data" roomId
         ON roomId."mid" = fromuid."mid"
        AND roomId."field" = 'roomId'
 INNER JOIN "message_data" timestamp
         ON timestamp."mid" = fromuid."mid"
        AND timestamp."field" = 'timestamp'
 INNER JOIN "message_data" content
         ON content."mid" = fromuid."mid"
        AND content."field" = 'content'
  LEFT JOIN "message_data" ip
         ON ip."mid" = fromuid."mid"
        AND ip."field" = 'ip'
 WHERE fromuid."field" = 'fromuid';

\o /dev/null
SELECT setval('classify.messages_mid_seq', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextMid')::BIGINT);
\o

ALTER TABLE "classify"."messages"
	ADD PRIMARY KEY ("mid"),
	CLUSTER ON "messages_pkey";
CREATE INDEX ON "classify"."messages"("roomId");
CREATE INDEX ON "classify"."messages"("timestamp");
CREATE INDEX ON "classify"."messages"("uid");
