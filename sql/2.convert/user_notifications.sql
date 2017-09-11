CREATE TABLE "user_notifications" (
	"uid" bigint NOT NULL,
	"nid" text NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW(),
	"read" boolean NOT NULL DEFAULT false
) WITH (autovacuum_enabled = false);

INSERT INTO "user_notifications" SELECT
       i."score"::bigint "uid",
       n."value" "nid",
       to_timestamp(n."score"::double precision / 1000) "timestamp",
       r."read" "read"
  FROM (VALUES ('unread', false), ('read', true)) r("name", "read")
 CROSS JOIN "objects_legacy" i
 INNER JOIN "objects_legacy" n
    ON n."key0" = 'uid'
   AND n."key1" = ARRAY[i."score"::text, 'notifications', r."name"]
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid'];

ALTER TABLE "user_notifications" ADD PRIMARY KEY ("uid", "nid");

CREATE INDEX "idx__user_notifications__uid__read__timestamp" ON "user_notifications"("uid", "read", "timestamp" DESC);

ALTER TABLE "user_notifications"
      CLUSTER ON "user_notifications_pkey";
