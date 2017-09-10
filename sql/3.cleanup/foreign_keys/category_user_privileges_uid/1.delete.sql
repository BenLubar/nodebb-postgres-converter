DELETE FROM "category_user_privileges"
 USING "category_user_privileges" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "category_user_privileges"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
