DELETE FROM "topic_tags"
 USING "topic_tags" t1
  LEFT OUTER JOIN "topics" t2
    ON t1."tid" = t2."tid"
 WHERE t1."tid" = "topic_tags"."tid"
   AND t2."tid" IS NULL
   AND t1."tid" IS NOT NULL;
