DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_notifications" un
 INNER JOIN "classify"."notifications" n
         ON n."nid" = un."nid"
 WHERE uc."_key" = 'uid:' || un."uid" || ':notifications:' || CASE WHEN un."read" THEN '' ELSE 'un' END || 'read'
   AND uc."type" = 'zset'
   AND uc."unique_string" = n."nid_legacy"
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM un."datetime") * 1000)::NUMERIC;
