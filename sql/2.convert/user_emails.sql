CREATE TABLE "user_emails" (
	"uid" bigint NOT NULL,
	"email" text NOT NULL,
	"changed_at" timestamptz NOT NULL DEFAULT NOW()
) WITH (autovacuum_enabled = false);

INSERT INTO "user_emails" SELECT
       i."score"::bigint "uid",
       trim(TRAILING ':' FROM trim(TRAILING '0123456789' FROM u."value")) "email",
       to_timestamp(u."score"::double precision / 1000) "changed_at"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" u
    ON u."key0" = 'user'
   AND u."key1" = ARRAY[i."score"::text, 'emails']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid'];

CREATE INDEX "idx__user_emails__uid__changed_at" ON "user_emails"("uid", "changed_at" DESC);

CREATE INDEX "idx__user_emails__email" ON "user_emails"("email");

ALTER TABLE "user_emails"
      CLUSTER ON "idx__user_emails__uid__changed_at";
