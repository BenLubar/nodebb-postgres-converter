DELETE FROM "post_votes"
 USING "post_votes" t1
  LEFT OUTER JOIN "posts" t2
    ON t1."pid" = t2."pid"
 WHERE t1."pid" = "post_votes"."pid"
   AND t2."pid" IS NULL
   AND t1."pid" IS NOT NULL;
