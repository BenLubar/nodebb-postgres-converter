DELETE FROM "classify"."unclassified" uc
 USING "classify"."flag_history" fh
 WHERE uc."_key" = 'flag:' || fh."flagId" || ':history'
   AND uc."type" = 'zset'
   AND uc."unique_string"::JSONB = JSONB_BUILD_ARRAY(fh."uid",
       JSONB_STRIP_NULLS(JSONB_BUILD_OBJECT(
           'state', fh."state"::TEXT,
           'assignee', CASE WHEN fh."unset_assignee" THEN '' ELSE fh."assignee"::TEXT END
       )) || CASE WHEN fh."notes_updated" THEN '{"notes":null}' ELSE '{}' END::JSONB,
       (EXTRACT(EPOCH FROM fh."datetime") * 1000)::NUMERIC)
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM fh."datetime") * 1000)::NUMERIC;
