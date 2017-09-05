CREATE TABLE "objects_legacy" (
	"key0" text NOT NULL,
	"key1" text[] NOT NULL CHECK (array_remove("key1", NULL) = "key1"),
	"value" text,
	"score" numeric,
	"data" jsonb NOT NULL CHECK (NOT ("data" ? '_key') AND
	                             NOT ("data" ? 'value') AND
	                             NOT ("data" ? 'score')),

	CHECK("data" = '{}' OR ("value" IS NULL AND "score" IS NULL))
);

CREATE TABLE "objects_legacy_imported_set" (
	CHECK ("key0" IN ('_imported', '_telligent'))
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_imported_object" (
	CHECK ("key0" IN ('_imported_bookmark', '_imported_category', '_imported_favourite', '_imported_group', '_imported_message', '_imported_post', '_imported_room', '_imported_topic', '_imported_user', '_imported_vote'))
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_uid" (
	CHECK ("key0" = 'uid')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_pid" (
	CHECK ("key0" = 'pid')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_tid" (
	CHECK ("key0" = 'tid')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_user" (
	CHECK ("key0" = 'user')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_users" (
	CHECK ("key0" = 'users')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_post" (
	CHECK ("key0" = 'post')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_posts" (
	CHECK ("key0" = 'posts')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_topic" (
	CHECK ("key0" = 'topic')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_topics" (
	CHECK ("key0" = 'topics')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_cid" (
	CHECK ("key0" = 'cid')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_ip" (
	CHECK ("key0" = 'ip')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_group" (
	CHECK ("key0" = 'group')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_username" (
	CHECK ("key0" = 'username')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_email" (
	CHECK ("key0" = 'email')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_userslug" (
	CHECK ("key0" = 'userslug')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_analytics" (
	CHECK ("key0" = 'analytics')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_errors" (
	CHECK ("key0" = 'errors')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_message" (
	CHECK ("key0" = 'message')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_notifications" (
	CHECK ("key0" = 'notifications')
) INHERITS ("objects_legacy");

CREATE TABLE "objects_legacy_misc" (
	CHECK ("key0" NOT IN ('_imported', '_imported_bookmark', '_imported_category', '_imported_favourite', '_imported_group', '_imported_message', '_imported_post', '_imported_room', '_imported_topic', '_imported_user', '_imported_vote', '_telligent', 'uid', 'pid', 'tid', 'user', 'users', 'post', 'posts', 'topic', 'topics', 'cid', 'ip', 'group', 'username', 'email', 'userslug', 'analytics', 'errors', 'message', 'notifications'))
) INHERITS ("objects_legacy");

CREATE FUNCTION "fun__objects_legacy__insert"()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW."key0" IN ('_imported', '_telligent') THEN
		INSERT INTO "objects_legacy_imported_set" VALUES (NEW.*);
	ELSIF NEW."key0" IN ('_imported_bookmark', '_imported_category', '_imported_favourite', '_imported_group', '_imported_message', '_imported_post', '_imported_room', '_imported_topic', '_imported_user', '_imported_vote') THEN
		INSERT INTO "objects_legacy_imported_object" VALUES (NEW.*);
	ELSIF NEW."key0" = 'uid' THEN
		INSERT INTO "objects_legacy_uid" VALUES (NEW.*);
	ELSIF NEW."key0" = 'pid' THEN
		INSERT INTO "objects_legacy_pid" VALUES (NEW.*);
	ELSIF NEW."key0" = 'tid' THEN
		INSERT INTO "objects_legacy_tid" VALUES (NEW.*);
	ELSIF NEW."key0" = 'user' THEN
		INSERT INTO "objects_legacy_user" VALUES (NEW.*);
	ELSIF NEW."key0" = 'users' THEN
		INSERT INTO "objects_legacy_users" VALUES (NEW.*);
	ELSIF NEW."key0" = 'post' THEN
		INSERT INTO "objects_legacy_post" VALUES (NEW.*);
	ELSIF NEW."key0" = 'posts' THEN
		INSERT INTO "objects_legacy_posts" VALUES (NEW.*);
	ELSIF NEW."key0" = 'topic' THEN
		INSERT INTO "objects_legacy_topic" VALUES (NEW.*);
	ELSIF NEW."key0" = 'topics' THEN
		INSERT INTO "objects_legacy_topics" VALUES (NEW.*);
	ELSIF NEW."key0" = 'cid' THEN
		INSERT INTO "objects_legacy_cid" VALUES (NEW.*);
	ELSIF NEW."key0" = 'ip' THEN
		INSERT INTO "objects_legacy_ip" VALUES (NEW.*);
	ELSIF NEW."key0" = 'group' THEN
		INSERT INTO "objects_legacy_group" VALUES (NEW.*);
	ELSIF NEW."key0" = 'username' THEN
		INSERT INTO "objects_legacy_username" VALUES (NEW.*);
	ELSIF NEW."key0" = 'email' THEN
		INSERT INTO "objects_legacy_email" VALUES (NEW.*);
	ELSIF NEW."key0" = 'userslug' THEN
		INSERT INTO "objects_legacy_userslug" VALUES (NEW.*);
	ELSIF NEW."key0" = 'analytics' THEN
		INSERT INTO "objects_legacy_analytics" VALUES (NEW.*);
	ELSIF NEW."key0" = 'errors' THEN
		INSERT INTO "objects_legacy_errors" VALUES (NEW.*);
	ELSIF NEW."key0" = 'message' THEN
		INSERT INTO "objects_legacy_message" VALUES (NEW.*);
	ELSIF NEW."key0" = 'notifications' THEN
		INSERT INTO "objects_legacy_notifications" VALUES (NEW.*);
	ELSE
		INSERT INTO "objects_legacy_misc" VALUES (NEW.*);
	END IF;
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER "tr__objects_legacy__insert"
BEFORE INSERT ON "objects_legacy"
FOR EACH ROW EXECUTE PROCEDURE "fun__objects_legacy__insert"();
