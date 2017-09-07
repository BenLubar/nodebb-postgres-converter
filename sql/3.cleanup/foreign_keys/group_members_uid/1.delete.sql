DELETE FROM "group_members"
 USING "group_members" t1
  LEFT OUTER JOIN "users" t2
    ON t1."uid" = t2."uid"
 WHERE t1."groupName" = "group_members"."groupName"
   AND t1."uid" = "group_members"."uid"
   AND t2."uid" IS NULL
   AND t1."uid" IS NOT NULL;
