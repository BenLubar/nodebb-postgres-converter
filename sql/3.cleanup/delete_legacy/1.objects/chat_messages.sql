DELETE FROM "objects_legacy" m
 USING generate_series(0, (SELECT ("data"->>'nextMid')::bigint
                             FROM "objects_legacy"
			    WHERE "key0" = 'global'
		              AND "key1" = ARRAY[]::text[])) i(i)
 WHERE m."key0" = 'message'
   AND m."key1" = ARRAY[i.i::text];
