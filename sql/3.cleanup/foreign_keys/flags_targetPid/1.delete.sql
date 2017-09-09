DELETE FROM "flags"
 USING "flags" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."targetPid" = t2."pid"
 WHERE t1."flagId" = "flags"."flagId"
   AND t2."pid" IS NULL
   AND t1."targetPid" IS NOT NULL;
