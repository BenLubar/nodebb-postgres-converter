DELETE FROM "topics"
 USING "topics" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."cid" = t2."cid"
 WHERE t1."tid" = "topics"."tid"
   AND t2."cid" IS NULL
   AND t1."cid" IS NOT NULL;

ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__cid"
      FOREIGN KEY ("cid")
      REFERENCES "categories"("cid")
      ON DELETE CASCADE;
