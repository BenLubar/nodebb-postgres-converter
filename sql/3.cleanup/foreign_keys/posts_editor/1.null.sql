UPDATE "posts"
   SET "editor" = NULL
  FROM "posts" t1
  LEFT OUTER JOIN "users" t2
    ON t1."editor" = t2."uid"
 WHERE t1."pid" = "posts"."pid"
   AND t2."uid" IS NULL
   AND t1."editor" IS NOT NULL;
