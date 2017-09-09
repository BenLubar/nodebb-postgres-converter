CREATE TABLE "chat_room_members" (
	"roomId" bigint NOT NULL,
	"uid" bigint NOT NULL,
	"joined_at" timestamptz NOT NULL DEFAULT NOW()
);

INSERT INTO "chat_room_members" SELECT
       i.i::bigint "roomId",
       m."value"::bigint "uid",
       to_timestamp(m."score"::double precision / 1000) "joined_at"
  FROM generate_series(0, (SELECT ("data"->>'nextChatRoomId')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i)
 INNER JOIN "objects_legacy" m
    ON m."key0" = 'chat'
   AND m."key1" = ARRAY['room', i.i::text, 'uids'];

ALTER TABLE "chat_room_members" ADD PRIMARY KEY ("roomId", "uid");

ALTER TABLE "chat_room_members"
      CLUSTER ON "chat_room_members_pkey";
