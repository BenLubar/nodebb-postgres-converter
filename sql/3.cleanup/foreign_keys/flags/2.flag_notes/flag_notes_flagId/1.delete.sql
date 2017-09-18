DELETE FROM "flag_notes"
 USING "flag_notes" t1
  LEFT OUTER JOIN "flags" t2
    ON t1."flagId" = t2."flagId"
 WHERE t1."flagId" = "flag_notes"."flagId"
   AND t2."flagId" IS NULL
   AND t1."flagId" IS NOT NULL;
