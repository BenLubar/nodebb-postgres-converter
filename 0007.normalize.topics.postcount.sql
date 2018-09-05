UPDATE "classify"."topics" t
   SET "postcount" = (SELECT COUNT(*)
                        FROM "classify"."posts" p
                       WHERE t."tid" = p."tid");
