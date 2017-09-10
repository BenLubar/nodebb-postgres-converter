DELETE FROM "category_group_privileges"
 USING "category_group_privileges" t1
  LEFT OUTER JOIN "groups" t2
    ON t1."groupName" = t2."name"
 WHERE t1."groupName" = "category_group_privileges"."groupName"
   AND t2."name" IS NULL
   AND t1."groupName" IS NOT NULL;
