DELETE FROM "classify"."unclassified" uc
 USING "classify"."notifications" n
 WHERE uc."_key" = 'notifications'
   AND uc."type" = 'zset'
   AND uc."unique_string" = n."nid_legacy"
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM n."datetime") * 1000)::NUMERIC;
