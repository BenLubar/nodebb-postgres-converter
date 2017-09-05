UPDATE "topics"
   SET "oldCid" = NULL
  FROM "topics" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."oldCid" = t2."cid"
 WHERE t1."tid" = "topics"."tid"
   AND t2."cid" IS NULL
   AND t1."oldCid" IS NOT NULL;

ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__oldCid"
      FOREIGN KEY ("oldCid")
      REFERENCES "categories"("cid")
      ON DELETE SET NULL;
