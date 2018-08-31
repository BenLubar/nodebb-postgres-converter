CREATE UNLOGGED TABLE "classify"."search_settings" (
	"default_language" REGCONFIG NOT NULL,
	"post_limit" BIGINT NOT NULL,
	"topic_limit" BIGINT NOT NULL
) WITHOUT OIDS;

-- only allow one row.
CREATE UNIQUE INDEX ON "classify"."search_settings"((1));

INSERT INTO "classify"."search_settings"
SELECT CASE (SELECT "value_string"
               FROM "classify"."unclassified"
              WHERE "_key" = 'nodebb-plugin-dbsearch'
                AND "type" = 'hash'
                AND "unique_string" = 'indexLanguage')
       WHEN 'da' THEN 'pg_catalog.danish'
       WHEN 'de' THEN 'pg_catalog.german'
       WHEN 'es' THEN 'pg_catalog.spanish'
       WHEN 'fi' THEN 'pg_catalog.finnish'
       WHEN 'fr' THEN 'pg_catalog.french'
       WHEN 'hu' THEN 'pg_catalog.hungarian'
       WHEN 'it' THEN 'pg_catalog.italian'
       WHEN 'nb' THEN 'pg_catalog.norwegian'
       WHEN 'nl' THEN 'pg_catalog.dutch'
       WHEN 'pt' THEN 'pg_catalog.portuguese'
       WHEN 'ro' THEN 'pg_catalog.romanian'
       WHEN 'ru' THEN 'pg_catalog.russian'
       WHEN 'sv' THEN 'pg_catalog.swedish'
       WHEN 'tr' THEN 'pg_catalog.turkish'
       ELSE 'pg_catalog.english'
       END,
       COALESCE((SELECT "value_string"
                   FROM "classify"."unclassified"
                  WHERE "_key" = 'nodebb-plugin-dbsearch'
                    AND "type" = 'hash'
                    AND "unique_string" = 'postLimit'), '500')::BIGINT,
       COALESCE((SELECT "value_string"
                   FROM "classify"."unclassified"
                  WHERE "_key" = 'nodebb-plugin-dbsearch'
                    AND "type" = 'hash'
                    AND "unique_string" = 'topicLimit'), '500')::BIGINT;
