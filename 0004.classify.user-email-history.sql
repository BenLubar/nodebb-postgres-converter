CREATE TABLE "classify"."user_email_history" (
	"history_id" BIGSERIAL NOT NULL,
	"uid" BIGINT NOT NULL,
	"email" TEXT COLLATE "C" NOT NULL,
	"changed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT OIDS;

INSERT INTO "classify"."user_email_history"
SELECT NEXTVAL('classify.user_email_history_history_id_seq'::REGCLASS),
       SPLIT_PART("_key", ':', 2)::BIGINT,
       REGEXP_REPLACE("unique_string", ':[0-9]+$', ''),
       TO_TIMESTAMP("value_numeric" / 1000)
  FROM "classify"."unclassified"
 WHERE "_key" SIMILAR TO 'user:[0-9]+:emails'
 ORDER BY "value_numeric" ASC;

ALTER TABLE "classify"."user_email_history"
	ADD PRIMARY KEY ("history_id"),
	CLUSTER ON "user_email_history_pkey";
CREATE INDEX ON "classify"."user_email_history"("uid", "changed_at");
CREATE INDEX ON "classify"."user_email_history"("email");
