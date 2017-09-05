CREATE TABLE "chat_messages" (
	"mid" bigserial NOT NULL,
	"roomId" bigint NOT NULL,
	"fromuid" bigint,
	"content" text NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW(),
	"edited" timestamptz DEFAULT NULL,
	"data" jsonb NOT NULL DEFAULT '{}'
);

INSERT INTO "chat_messages" SELECT
       i.i "mid",
       COALESCE(NULLIF(m."data"->>'roomId', ''), '0')::bigint "roomId",
       NULLIF(NULLIF(m."data"->>'fromuid', ''), '0')::bigint "fromuid",
       m."data"->>'content' "content",
       to_timestamp(NULLIF(NULLIF(m."data"->>'timestamp', ''), '0')::double precision / 1000) "timestamp",
       to_timestamp(NULLIF(NULLIF(m."data"->>'edited', ''), '0')::double precision / 1000) "edited",
       m."data" - 'roomId' - 'fromuid' - 'content' - 'edited' - 'timestamp' "data"
  FROM generate_series(0, (SELECT ("data"->>'nextMid')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i),
       "objects_legacy" m
 WHERE m."key0" = 'message'
   AND m."key1" = ARRAY[i.i::text];

DO $$
DECLARE
	"nextMid" bigint;
BEGIN
	SELECT "data"->>'nextMid' INTO "nextMid"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "chat_messages_mid_seq" RESTART WITH ' || ("nextMid" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "chat_messages" ADD PRIMARY KEY ("mid");

CLUSTER "chat_messages" USING "chat_messages_pkey";

ANALYZE "chat_messages";
