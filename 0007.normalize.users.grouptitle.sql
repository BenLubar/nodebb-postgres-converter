ALTER TABLE "classify"."users"
	ALTER "groupTitle" TYPE BIGINT
	USING (SELECT g."gid"
	         FROM "classify"."groups" g
	        WHERE g."name" = "groupTitle");
