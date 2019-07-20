CREATE TEMPORARY TABLE "notification_data" ON COMMIT DROP AS
SELECT SUBSTRING("_key" FROM LENGTH('notifications:') + 1) "nid",
       "unique_string" "field",
       "value_string" "value"
  FROM "classify"."unclassified"
 WHERE "_key" LIKE 'notifications:%'
   AND "type" = 'hash';

ALTER TABLE "notification_data"
	ADD PRIMARY KEY ("nid", "field"),
	CLUSTER ON "notification_data_pkey";

ANALYZE "notification_data";

CREATE TABLE "classify"."notifications" (
	"nid" BIGSERIAL NOT NULL,
	"nid_legacy" TEXT COLLATE "C" NOT NULL,
	"path" TEXT COLLATE "C",
	"bodyShort" TEXT COLLATE "C" NOT NULL,
	"importance" INT NOT NULL,
	"datetime" TIMESTAMPTZ NOT NULL,

	"bodyLong" TEXT COLLATE "C",
	"type" TEXT COLLATE "C",
	"from" BIGINT,
	"pid" BIGINT,
	"tid" BIGINT,
	"mergeId" TEXT COLLATE "C",
	"topicTitle" TEXT COLLATE "C",
	"subject" TEXT COLLATE "C"
) WITHOUT OIDS;

INSERT INTO "classify"."notifications"
SELECT NEXTVAL('classify.notifications_nid_seq'::REGCLASS),
       nid."unique_string",
       path."value",
       bodyShort."value",
       importance."value"::INT,
       TO_TIMESTAMP(datetime."value"::NUMERIC / 1000),
       NULLIF(bodyLong."value", ''),
       NULLIF(type."value", ''),
       NULLIF(NULLIF(from_."value", ''), '0')::BIGINT,
       NULLIF(NULLIF(pid."value", ''), '0')::BIGINT,
       NULLIF(NULLIF(tid."value", ''), '0')::BIGINT,
       NULLIF(mergeId."value", ''),
       NULLIF(topicTitle."value", ''),
       NULLIF(subject."value", '')
  FROM "classify"."unclassified" nid
  LEFT JOIN "notification_data" path
         ON path."nid" = nid."unique_string"
        AND path."field" = 'path'
  LEFT JOIN "notification_data" bodyShort
         ON bodyShort."nid" = nid."unique_string"
        AND bodyShort."field" = 'bodyShort'
  LEFT JOIN "notification_data" importance
         ON importance."nid" = nid."unique_string"
        AND importance."field" = 'importance'
  LEFT JOIN "notification_data" datetime
         ON datetime."nid" = nid."unique_string"
        AND datetime."field" = 'datetime'
  LEFT JOIN "notification_data" bodyLong
         ON bodyLong."nid" = nid."unique_string"
        AND bodyLong."field" = 'bodyLong'
  LEFT JOIN "notification_data" type
         ON type."nid" = nid."unique_string"
        AND type."field" = 'type'
  LEFT JOIN "notification_data" from_
         ON from_."nid" = nid."unique_string"
        AND from_."field" = 'from'
  LEFT JOIN "notification_data" pid
         ON pid."nid" = nid."unique_string"
        AND pid."field" = 'pid'
  LEFT JOIN "notification_data" tid
         ON tid."nid" = nid."unique_string"
        AND tid."field" = 'tid'
  LEFT JOIN "notification_data" mergeId
         ON mergeId."nid" = nid."unique_string"
        AND mergeId."field" = 'mergeId'
  LEFT JOIN "notification_data" topicTitle
         ON topicTitle."nid" = nid."unique_string"
        AND topicTitle."field" = 'topicTitle'
  LEFT JOIN "notification_data" subject
         ON subject."nid" = nid."unique_string"
        AND subject."field" = 'subject'
 WHERE nid."_key" = 'notifications'
   AND nid."type" = 'zset';

ALTER TABLE "classify"."notifications"
	ADD PRIMARY KEY ("nid"),
	CLUSTER ON "notifications_pkey";
CREATE UNIQUE INDEX ON "classify"."notifications"("nid_legacy");
CREATE INDEX ON "classify"."notifications"("datetime");

CREATE TABLE "classify"."user_notifications" (
	"uid" BIGINT NOT NULL,
	"nid" BIGINT NOT NULL,
	"datetime" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"read" BOOLEAN NOT NULL DEFAULT FALSE
) WITHOUT OIDS;

INSERT INTO "classify"."user_notifications"
SELECT SPLIT_PART(uc."_key", ':', 2)::BIGINT,
       n."nid",
       TO_TIMESTAMP(uc."value_numeric" / 1000),
       uc."_key" LIKE '%:read'
  FROM "classify"."unclassified" uc
 INNER JOIN "classify"."notifications" n
         ON n."nid_legacy" = uc."unique_string"
 WHERE uc."_key" SIMILAR TO 'uid:[0-9]+:notifications:(un)?read'
   AND uc."type" = 'zset';

ALTER TABLE "classify"."user_notifications"
	ADD PRIMARY KEY ("uid", "nid"),
	CLUSTER ON "user_notifications_pkey";
CREATE INDEX ON "classify"."user_notifications"("uid", "read", "datetime");
