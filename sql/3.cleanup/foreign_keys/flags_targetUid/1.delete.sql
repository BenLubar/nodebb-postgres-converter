DELETE FROM "flags"
 USING "flags" t1
  LEFT OUTER JOIN "users" t2
    ON t1."targetUid" = t2."uid"
 WHERE t1."flagId" = "flags"."flagId"
   AND t2."uid" IS NULL
   AND t1."targetUid" IS NOT NULL;
