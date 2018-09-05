CREATE TABLE "classify"."messages" (
	"mid" BIGSERIAL NOT NULL,
	"roomId" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"timestamp" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"content" TEXT COLLATE "C" NOT NULL,
	"ip" INET NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."messages"
SELECT mid."value_string"::BIGINT,
       roomId."value_string"::BIGINT,
       uid."value_string"::BIGINT,
       TO_TIMESTAMP(timestamp."value_string"::NUMERIC / 1000),
       content."value_string",
       SPLIT_PART(ip."value_string", ',', 1)::INET
  FROM "classify"."unclassified" mid
 INNER JOIN "classify"."unclassified" roomId
         ON roomId."_key" = mid."_key"
        AND roomId."type" = 'hash'
        AND roomId."unique_string" = 'roomId'
 INNER JOIN "classify"."unclassified" uid
         ON uid."_key" = mid."_key"
        AND uid."type" = 'hash'
        AND uid."unique_string" = 'uid'
 INNER JOIN "classify"."unclassified" timestamp
         ON timestamp."_key" = mid."_key"
        AND timestamp."type" = 'hash'
        AND timestamp."unique_string" = 'timestamp'
 INNER JOIN "classify"."unclassified" content
         ON content."_key" = mid."_key"
        AND content."type" = 'hash'
        AND content."unique_string" = 'content'
 INNER JOIN "classify"."unclassified" ip
         ON ip."_key" = mid."_key"
        AND ip."type" = 'hash'
        AND ip."unique_string" = 'ip'
 WHERE mid."_key" SIMILAR TO 'message:[0-9]+'
   AND mid."type" = 'hash'
   AND mid."unique_string" = 'mid'
   AND mid."value_string" = SPLIT_PART(mid."_key", ':', 2);

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
CREATE INDEX ON "classify"."messages"("roomId", "timestamp");
CREATE INDEX ON "classify"."messages"("uid");
