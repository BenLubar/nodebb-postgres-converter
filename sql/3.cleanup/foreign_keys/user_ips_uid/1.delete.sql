DELETE FROM "user_ips"
 USING "user_ips" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "user_ips"."uid"
   AND t1."ip" = "user_ips"."ip"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
