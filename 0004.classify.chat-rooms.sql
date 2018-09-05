CREATE TABLE "classify"."chat_rooms" (
	"roomId" BIGSERIAL NOT NULL,
	"roomName" TEXT COLLATE "C",
	"owner" BIGINT,
	"groupChat" BOOLEAN NOT NULL DEFAULT FALSE
) WITHOUT OIDS;

INSERT INTO "classify"."chat_rooms"
SELECT roomId."value_string"::BIGINT,
       NULLIF(roomName."value_string", ''),
       NULLIF(NULLIF(owner."value_string", ''), '0')::BIGINT,
       groupChat."value_string" IS NOT NULL
  FROM "classify"."unclassified" roomId
  LEFT JOIN "classify"."unclassified" roomName
         ON roomName."_key" = roomId."_key"
        AND roomName."type" = 'hash'
        AND roomName."unique_string" = 'roomName'
  LEFT JOIN "classify"."unclassified" owner
         ON owner."_key" = roomId."_key"
        AND owner."type" = 'hash'
        AND owner."unique_string" = 'owner'
  LEFT JOIN "classify"."unclassified" groupChat
         ON groupChat."_key" = roomId."_key"
        AND groupChat."type" = 'hash'
        AND groupChat."unique_string" = 'groupChat'
        AND groupChat."value_string" = '1'
 WHERE roomId."_key" SIMILAR TO 'chat:room:[0-9]+'
   AND roomId."type" = 'hash'
   AND roomId."unique_string" = 'roomId'
   AND roomId."value_string" = SPLIT_PART(roomId."_key", ':', 3);

\o /dev/null
SELECT setval('classify."chat_rooms_roomId_seq"', (
	SELECT "value_string"
	  FROM "classify"."unclassified"
	 WHERE "_key" = 'global'
	   AND "type" = 'hash'
	   AND "unique_string" = 'nextChatRoomId')::BIGINT);
\o

ALTER TABLE "classify"."chat_rooms"
	ADD PRIMARY KEY ("roomId"),
	CLUSTER ON "chat_rooms_pkey";
CREATE INDEX ON "classify"."chat_rooms"("owner");
