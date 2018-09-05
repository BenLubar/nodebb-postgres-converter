CREATE TABLE "classify"."chat_room_users" (
	"roomId" BIGINT NOT NULL,
	"uid" BIGINT NOT NULL,
	"added_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."chat_room_users"
SELECT SPLIT_PART("_key", ':', 3)::BIGINT,
       "unique_string"::BIGINT,
       TO_TIMESTAMP("value_numeric" / 1000)
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'chat:room:[0-9]+:uids'
   AND "type" = 'zset';

ALTER TABLE "classify"."chat_room_users"
	ADD PRIMARY KEY ("roomId", "uid"),
	CLUSTER ON "chat_room_users_pkey";
CREATE INDEX ON "classify"."chat_room_users"("uid");
