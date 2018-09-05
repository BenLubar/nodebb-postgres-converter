CREATE TABLE "classify"."tdwtf_post_cache" (
	"pid" BIGINT NOT NULL,
	"content" TEXT COLLATE "C" NOT NULL,
	"version" INT NOT NULL
) WITHOUT OIDS;

INSERT INTO "classify"."tdwtf_post_cache"
SELECT SPLIT_PART(c."_key", ':', 2)::BIGINT,
       c."value_string",
       v."value_string"::INT
  FROM "classify"."unclassified" c
 INNER JOIN "classify"."unclassified" v
         ON v."_key" = c."_key"
        AND v."type" = 'hash'
        AND v."unique_string" = 'version'
 WHERE c."_key" SIMILAR TO 'tdwtf-post-cache:[0-9]+'
   AND c."type" = 'hash'
   AND c."unique_string" = 'content';

ALTER TABLE "classify"."tdwtf_post_cache"
	ADD PRIMARY KEY ("pid"),
	CLUSTER ON "tdwtf_post_cache_pkey";
CREATE INDEX ON "classify"."tdwtf_post_cache"("version");
