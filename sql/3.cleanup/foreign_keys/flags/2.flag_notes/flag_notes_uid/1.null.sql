UPDATE "flag_notes"
   SET "uid" = NULL
  FROM "flags" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "flag_notes"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
