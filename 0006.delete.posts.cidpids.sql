DELETE FROM "classify"."unclassified" uc
 USING "classify"."posts" p
 INNER JOIN "classify"."topics" t
         ON p."tid" = t."tid"
 WHERE uc."_key" = 'cid:' || t."cid" || ':pids'
   AND uc."type" = 'zset'
   AND uc."unique_string" = p."pid"::TEXT
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM p."timestamp") * 1000)::NUMERIC;
