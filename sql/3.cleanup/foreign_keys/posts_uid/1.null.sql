UPDATE "posts"
   SET "uid" = NULL
  FROM "posts" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."pid" = "posts"."pid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
