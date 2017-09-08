CREATE TABLE "post_votes" (
	"pid" bigint NOT NULL,
	"uid" bigint NOT NULL,
	"up" boolean NOT NULL,
	"timestamp" timestamptz NOT NULL DEFAULT NOW()
);

INSERT INTO "post_votes" SELECT
       v."value"::bigint "pid",
       i."score"::bigint "uid",
       true "up",
       to_timestamp(v."score"::double precision / 1000) "timestamp"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" v
    ON v."key0" = 'uid'
   AND v."key1" = ARRAY[i."score"::text, 'upvote']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid']
 UNION ALL
SELECT v."value"::bigint "pid",
       i."score"::bigint "uid",
       false "up",
       to_timestamp(v."score"::double precision / 1000) "timestamp"
  FROM "objects_legacy" i
 INNER JOIN "objects_legacy" v
    ON v."key0" = 'uid'
   AND v."key1" = ARRAY[i."score"::text, 'downvote']
 WHERE i."key0" = 'username'
   AND i."key1" = ARRAY['uid'];

ALTER TABLE "post_votes" ADD PRIMARY KEY ("pid", "uid");

CREATE INDEX "idx__post_votes__pid__up__timestamp" ON "post_votes"("pid", "up", "timestamp");

CREATE INDEX "idx__post_votes__uid__up__timestamp" ON "post_votes"("uid", "up", "timestamp");

ALTER TABLE "post_votes"
      CLUSTER ON "post_votes_pkey";
