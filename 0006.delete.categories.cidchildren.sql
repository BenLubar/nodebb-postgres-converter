DELETE FROM "classify"."unclassified" uc
 USING "classify"."categories" c
 WHERE uc."_key" = 'cid:' || COALESCE(c."parentCid", 0) || ':children'
   AND uc."type" = 'zset'
   AND uc."unique_string" = c."cid"::TEXT
   AND uc."value_numeric" = c."order"::NUMERIC;
