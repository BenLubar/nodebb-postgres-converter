DELETE FROM "user_usernames"
 USING "user_usernames" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "user_usernames"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
