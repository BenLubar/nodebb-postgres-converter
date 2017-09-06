UPDATE "posts"
   SET "deleterUid" = NULL
  FROM "posts" t1
  LEFT OUTER JOIN "users" t2
    ON t1."deleterUid" = t2."uid"
 WHERE t1."pid" = "posts"."pid"
   AND t2."uid" IS NULL
   AND t1."deleterUid" IS NOT NULL;
