DELETE FROM "classify"."unclassified" uc
 USING "classify"."notifications" n
 WHERE uc."_key" = 'notifications:' || n."nid_legacy"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'path'
   AND uc."value_string" = n."path";
