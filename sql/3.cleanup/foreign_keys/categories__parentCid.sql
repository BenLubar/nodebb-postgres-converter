UPDATE "categories"
   SET "parentCid" = NULL
  FROM "categories" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."parentCid" = t2."cid"
 WHERE t1."cid" = "categories"."cid"
   AND t2."cid" IS NULL
   AND t1."parentCid" IS NOT NULL;

ALTER TABLE "categories" 
  ADD CONSTRAINT "fk__categories__parentCid"
      FOREIGN KEY ("parentCid")
      REFERENCES "categories"("cid")
      ON DELETE SET NULL;
