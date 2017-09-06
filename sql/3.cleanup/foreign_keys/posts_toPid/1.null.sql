UPDATE "posts"
   SET "toPid" = NULL
  FROM "posts" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."toPid" = t2."pid"
 WHERE t1."pid" = "posts"."pid"
   AND t2."pid" IS NULL
   AND t1."toPid" IS NOT NULL;
