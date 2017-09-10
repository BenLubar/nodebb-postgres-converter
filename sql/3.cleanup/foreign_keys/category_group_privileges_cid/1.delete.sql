DELETE FROM "category_group_privileges"
 USING "category_group_privileges" t1
  LEFT OUTER JOIN "categories" t2
    ON t1."cid" = t2."cid"
 WHERE t1."cid" = "category_group_privileges"."cid"
   AND t2."cid" IS NULL
   AND t1."cid" IS NOT NULL;
