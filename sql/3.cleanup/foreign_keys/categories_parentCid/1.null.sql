UPDATE "categories"
   SET "parentCid" = NULL
  FROM "categories" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."parentCid" = t2."cid"
 WHERE t1."cid" = "categories"."cid"
   AND t2."cid" IS NULL
   AND t1."parentCid" IS NOT NULL;
