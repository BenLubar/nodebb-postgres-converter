ALTER TABLE "classify"."users"
	ADD "groupTitle_gid" BIGINT;

UPDATE "classify"."users" u
   SET "groupTitle_gid" = g."gid"
  FROM "classify"."groups" g
 WHERE g."name" = u."groupTitle";

ALTER TABLE "classify"."users"
	ALTER "groupTitle" TYPE BIGINT USING "groupTitle_gid",
	DROP "groupTitle_gid";
