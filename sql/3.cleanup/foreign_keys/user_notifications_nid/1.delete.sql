DELETE FROM "user_notifications"
 USING "user_notifications" t1
  LEFT OUTER JOIN "notifications" t2
    ON t1."nid" = t2."nid"
 WHERE t1."nid" = "user_notifications"."nid"
   AND t2."nid" IS NULL
   AND t1."nid" IS NOT NULL;
