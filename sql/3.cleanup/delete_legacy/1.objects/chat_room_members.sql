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

DELETE FROM "objects_legacy" r
 WHERE r."key0" = 'uid'
   AND array_length(r."key1", 1) = 5
   AND EXISTS(SELECT 1
                FROM "objects_legacy" u
               WHERE u."key0" = 'username'
                 AND u."key1" = ARRAY['uid']
                 AND u."score"::text = r."key1"[1])
   AND r."key1"[2:3] = ARRAY['chat', 'room']
   AND CASE WHEN r."key1"[4] ~ '^[0-9]+$'
       THEN r."key1"[4]::bigint BETWEEN 0
        AND (SELECT ("data"->>'nextChatRoomId')::bigint
               FROM "objects_legacy"
              WHERE "key0" = 'global'
                AND "key1" = ARRAY[]::text[])
        END
   AND r."key1"[5] = 'mids';
