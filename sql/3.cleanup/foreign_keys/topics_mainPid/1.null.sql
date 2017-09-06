UPDATE "topics"
   SET "mainPid" = NULL
  FROM "topics" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."mainPid" = t2."pid"
 WHERE t1."tid" = "topics"."tid"
   AND t2."pid" IS NULL
   AND t1."mainPid" IS NOT NULL;
