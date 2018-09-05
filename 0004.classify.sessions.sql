CREATE TABLE "classify"."sessions" (
	"sid" CHAR(32) COLLATE "C" NOT NULL,
	"uuid" UUID NOT NULL DEFAULT GEN_RANDOM_UUID(),
	"uid" BIGINT,
	"expires_at" TIMESTAMPTZ NOT NULL,
	"logged_in_at" TIMESTAMPTZ,
	"csrfSecret" CHAR(32) COLLATE "C",
	"ips" INET[] NOT NULL DEFAULT '{}',
	"browser" TEXT COLLATE "C",
	"version" TEXT COLLATE "C",
	"platform" TEXT COLLATE "C",
	"data" JSONB NOT NULL DEFAULT '{}'
) WITHOUT OIDS;

INSERT INTO "classify"."sessions"
SELECT "sid",
       COALESCE(NULLIF("sess"->'meta'->>'uuid', '')::UUID, GEN_RANDOM_UUID()),
       NULLIF("sess"->'passport'->>'user', '')::BIGINT,
       "expire",
       TO_TIMESTAMP(NULLIF("sess"->'meta'->>'datetime', '')::NUMERIC / 1000),
       NULLIF("sess"->>'csrfSecret', ''),
       ('{' || COALESCE("sess"->'meta'->>'ip', '') || '}')::INET[],
       NULLIF("sess"->'meta'->>'browser', ''),
       NULLIF("sess"->'meta'->>'version', ''),
       NULLIF("sess"->'meta'->>'platform', ''),
       "sess" - 'meta' - 'cookie' - 'csrfSecret' - 'passport'
  FROM "session";

CREATE INDEX ON "classify"."sessions"("expires_at");
ALTER TABLE "classify"."sessions"
	ADD PRIMARY KEY ("sid"),
	CLUSTER ON "sessions_expires_at_idx";
CREATE INDEX ON "classify"."sessions"("uuid");
CREATE INDEX ON "classify"."sessions"("uid");
CREATE INDEX ON "classify"."sessions" USING GIN("ips");
