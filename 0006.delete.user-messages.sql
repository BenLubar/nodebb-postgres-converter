DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_messages" um
 INNER JOIN "classify"."messages" m
         ON m."mid" = um."mid"
 WHERE uc."_key" = 'uid:' || um."uid" || ':chat:room:' || m."roomId" || ':mids'
   AND uc."type" = 'zset'
   AND uc."unique_string" = um."mid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM m."timestamp") * 1000)::NUMERIC;
