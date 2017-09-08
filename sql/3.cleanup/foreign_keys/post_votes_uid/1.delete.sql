DELETE FROM "post_votes"
 USING "post_votes" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."uid" = "post_votes"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
