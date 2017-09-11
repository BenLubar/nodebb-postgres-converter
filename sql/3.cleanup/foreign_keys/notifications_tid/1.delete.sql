DELETE FROM "notifications"
 USING "notifications" t1
  LEFT OUTER JOIN "topics" t2
    ON t1."tid" = t2."tid"
 WHERE t1."nid" = "notifications"."nid"
   AND t2."tid" IS NULL
   AND t1."tid" IS NOT NULL;
