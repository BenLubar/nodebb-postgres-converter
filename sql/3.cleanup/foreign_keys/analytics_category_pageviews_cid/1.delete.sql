DELETE FROM "analytics_category_pageviews"
 USING "analytics_category_pageviews" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."cid" = t2."cid"
 WHERE t1."cid" = "analytics_category_pageviews"."cid"
   AND t2."cid" IS NULL
   AND t1."cid" IS NOT NULL;
