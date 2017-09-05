DELETE FROM "objects_legacy" r
 USING generate_series(0, (SELECT ("data"->>'nextChatRoomId')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i)
 WHERE r."key0" = 'chat'
   AND r."key1" = ARRAY['room', i.i::text];
