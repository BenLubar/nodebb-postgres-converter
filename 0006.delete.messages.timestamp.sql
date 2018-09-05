DELETE FROM "classify"."unclassified" uc
 USING "classify"."messages" m
 WHERE uc."_key" = 'message:' || m."mid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'timestamp'
   AND uc."value_string" = (EXTRACT(EPOCH FROM m."timestamp") * 1000)::BIGINT::TEXT;
