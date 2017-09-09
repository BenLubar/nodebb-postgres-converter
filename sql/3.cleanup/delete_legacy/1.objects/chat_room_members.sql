DELETE FROM "objects_legacy" m
 USING generate_series(0, (SELECT ("data"->>'nextChatRoomId')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i)
 WHERE m."key0" = 'chat'
   AND m."key1" = ARRAY['room', i.i::text, 'uids'];

DELETE FROM "objects_legacy" r
 USING "objects_legacy" i
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
   AND r."key0" = 'uid'
   AND r."key1" = ARRAY[i."score"::text, 'chat', 'rooms'];
