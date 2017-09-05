UPDATE "topics"
   SET "teaserPid" = NULL
  FROM "topics" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."teaserPid" = t2."pid"
 WHERE t1."tid" = "topics"."tid"
   AND t2."pid" IS NULL
   AND t1."teaserPid" IS NOT NULL;

ALTER TABLE "topics" 
  ADD CONSTRAINT "fk__topics__teaserPid"
      FOREIGN KEY ("teaserPid")
      REFERENCES "posts"("pid")
      ON DELETE SET NULL;
