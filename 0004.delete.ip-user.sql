DELETE FROM "classify"."unclassified" uc
 USING "classify"."ip_user" iu
 WHERE (uc."_key" = 'ip:' || HOST(iu."ip") || ':uid'
    OR  uc."_key" = 'ip:::ffff:' || HOST(iu."ip") || ':uid')
   AND uc."type" = 'zset'
   AND uc."unique_string" = iu."uid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM iu."last_seen") * 1000)::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."ip_user" iu
 WHERE uc."_key" = 'uid:' || iu."uid" || ':ip'
   AND uc."type" = 'zset'
   AND (uc."unique_string" = HOST(iu."ip")
    OR  uc."unique_string" = '::ffff:' || HOST(iu."ip"))
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM iu."last_seen") * 1000)::NUMERIC;
