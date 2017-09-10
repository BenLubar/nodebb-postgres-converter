DELETE FROM "analytics_category_topics"
 USING "analytics_category_topics" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."cid" = t2."cid"
 WHERE t1."cid" = "analytics_category_topics"."cid"
   AND t2."cid" IS NULL
   AND t1."cid" IS NOT NULL;
