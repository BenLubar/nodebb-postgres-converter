DELETE FROM "classify"."unclassified" uc
 USING "classify"."sessions" s
 WHERE uc."_key" = 'uid:' || s."uid" || ':sessionUUID:sessionId'
   AND uc."type" = 'hash'
   AND uc."unique_string" = LOWER(s."uuid"::TEXT)
   AND uc."value_string" = s."sid";
