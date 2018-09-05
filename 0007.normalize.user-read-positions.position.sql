WITH ppos AS (
	SELECT p."tid",
	       p."pid",
	       CASE WHEN p."pid" = m."pid" THEN 1
	            WHEN p."timestamp" > m."timestamp" THEN ROW_NUMBER() OVER (PARTITION BY p."tid" ORDER BY p."timestamp")
	            ELSE ROW_NUMBER() OVER (PARTITION BY p."tid" ORDER BY p."timestamp") + 1 END "pos",
	       COUNT(*) OVER (PARTITION BY p."tid") "max"
	  FROM "classify"."posts" p
	 INNER JOIN "classify"."topics" t
	         ON t."tid" = p."tid"
	 INNER JOIN "classify"."posts" m
	         ON m."pid" = t."mainPid"
)
UPDATE "classify"."user_read_positions" urp
   SET "position" = ppos."pid"
  FROM ppos
 WHERE urp."tid" = ppos."tid"
   AND (urp."position" = ppos."pos"
    OR (urp."position" > ppos."pos" AND ppos."pos" = ppos."max"));

ALTER TABLE "classify"."user_read_positions"
	RENAME "position" TO "pid";
