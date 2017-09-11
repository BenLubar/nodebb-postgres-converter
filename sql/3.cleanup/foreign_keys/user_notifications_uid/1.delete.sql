DELETE FROM "user_notifications"
 USING "user_notifications" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "user_notifications"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
