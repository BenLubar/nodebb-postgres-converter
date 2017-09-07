UPDATE "events"
   SET "uid" = NULL
  FROM "events" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."eid" = "events"."eid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
