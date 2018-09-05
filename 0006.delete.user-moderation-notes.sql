DELETE FROM "classify"."unclassified" uc
 USING "classify"."user_moderation_notes" umn
 WHERE uc."_key" = 'uid:' || umn."uid" || ':moderation:notes'
   AND uc."type" = 'zset'
   AND uc."unique_string"::JSONB = JSONB_BUILD_OBJECT('uid', umn."moderator_id", 'note', umn."note", 'timestamp', (EXTRACT(EPOCH FROM umn."timestamp") * 1000)::BIGINT)
   AND uc."value_numeric" = (EXTRACT(EPOCH FROM umn."timestamp") * 1000)::NUMERIC;
