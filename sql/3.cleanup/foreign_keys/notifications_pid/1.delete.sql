DELETE FROM "notifications"
 USING "notifications" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."pid" = t2."pid"
 WHERE t1."nid" = "notifications"."nid"
   AND t2."pid" IS NULL
   AND t1."pid" IS NOT NULL;
