CREATE TABLE "chat_rooms" (
	"roomId" bigserial NOT NULL,
	"owner" bigint NOT NULL,
	"roomName" text NOT NULL,
	"groupChat" boolean NOT NULL DEFAULT false,
	"data" jsonb NOT NULL DEFAULT '{}'
);

INSERT INTO "chat_rooms" SELECT
       i.i::bigint "roomId",
       NULLIF(NULLIF(r."data"->>'owner', ''), '0')::bigint "owner",
       COALESCE(r."data"->>'roomName', '') "roomName",
       COALESCE(r."data"->>'groupChat', '0') = '1' "groupChat",
       r."data" - 'roomId' - 'owner' - 'roomName' - 'groupChat' "data"
  FROM generate_series(0, (SELECT ("data"->>'nextChatRoomId')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i)
 INNER JOIN "objects_legacy" r
    ON r."key0" = 'chat'
   AND r."key1" = ARRAY['room', i.i::text];

DO $$
DECLARE
	"nextChatRoomId" bigint;
BEGIN
	SELECT "data"->>'nextChatRoomId' INTO "nextChatRoomId"
	  FROM "objects_legacy"
	 WHERE "key0" = 'global'
	   AND "key1" = ARRAY[]::text[];

	EXECUTE 'ALTER SEQUENCE "chat_rooms_roomId_seq" RESTART WITH ' || ("nextChatRoomId" + 1) || ';';
END;
$$ LANGUAGE plpgsql;

ALTER TABLE "chat_rooms" ADD PRIMARY KEY ("roomId");

CLUSTER "chat_rooms" USING "chat_rooms_pkey";

ANALYZE "chat_rooms";
