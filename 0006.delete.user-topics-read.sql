DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_topics_read" utr
WHERE uc."_key" = 'uid:' || utr."uid" || CASE WHEN utr."read" THEN ':tids_read' ELSE ':tids_unread' END
   AND uc."type" = 'zset'
   AND uc."unique_string" = utr."tid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM utr."timestamp") * 1000)::NUMERIC;
