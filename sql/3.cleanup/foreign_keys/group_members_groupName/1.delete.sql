DELETE FROM "group_members"
 USING "group_members" t1
  LEFT OUTER JOIN "groups" t2
    ON t1."groupName" = t2."name"
 WHERE t1."groupName" = "group_members"."groupName"
   AND t1."uid" = "group_members"."uid"
   AND t2."name" IS NULL
   AND t1."groupName" IS NOT NULL;
