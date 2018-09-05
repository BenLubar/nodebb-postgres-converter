CREATE TABLE "classify"."user_messages" (
	"uid" BIGINT NOT NULL,
	"mid" BIGINT NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."user_messages"
SELECT SPLIT_PART("_key", ':', 2)::BIGINT,
       "unique_string"::BIGINT
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'uid:[0-9]+:chat:room:[0-9]+:mids'
   AND "type" = 'zset';

ALTER TABLE "classify"."user_messages"
	ADD PRIMARY KEY ("uid", "mid"),
	CLUSTER ON "user_messages_pkey";
