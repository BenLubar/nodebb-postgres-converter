DELETE FROM "notifications"
 USING "notifications" t1
  LEFT OUTER JOIN "users" t2
    ON t1."from" = t2."uid"
 WHERE t1."nid" = "notifications"."nid"
   AND t2."uid" IS NULL
   AND t1."from" IS NOT NULL;
