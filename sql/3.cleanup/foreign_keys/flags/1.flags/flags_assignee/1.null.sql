UPDATE "flags"
   SET "assignee" = NULL
  FROM "flags" t1
  LEFT OUTER JOIN "users" t2
    ON t1."assignee" = t2."uid"
 WHERE t1."flagId" = "flags"."flagId"
   AND t2."uid" IS NULL
   AND t1."assignee" IS NOT NULL;
