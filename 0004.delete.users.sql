DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'uid'
   AND uc."value_string" = u."uid"::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'username:sorted'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."username"
   AND uc."value_numeric" = 0;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'username:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."username"
   AND uc."value_numeric" = u."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'username'
   AND uc."value_string" = u."username";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'userslug:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."userslug"
   AND uc."value_numeric" = u."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'userslug'
   AND uc."value_string" = u."userslug";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'email:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."email"
   AND uc."value_numeric" = u."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'email:sorted'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."email"
   AND uc."value_numeric" = 0;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'email'
   AND uc."value_string" = u."email";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'email:confirmed'
   AND uc."value_string" = CASE WHEN u."email:confirmed" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'password'
   AND uc."value_string" = u."password";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'passwordExpiry'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."passwordExpiry") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'joindate'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."joindate") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'lastonline'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."lastonline") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'lastposttime'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."lastposttime") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'lastqueuetime'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."lastqueuetime") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'rss_token'
   AND uc."value_string" = COALESCE(u."rss_token"::TEXT, '');

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'acceptTos'
   AND uc."value_string" = CASE WHEN u."acceptTos" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'gdpr_consent'
   AND uc."value_string" = CASE WHEN u."gdpr_consent" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'banned'
   AND uc."value_string" = CASE WHEN u."banned" THEN '1' ELSE '0' END;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'banned:expire'
   AND uc."value_string" = COALESCE(EXTRACT(EPOCH FROM u."banned:expire") * 1000, 0)::TEXT;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'moderationNote'
   AND uc."value_string" = u."moderationNote";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'fullname:uid'
   AND uc."type" = 'zset'
   AND uc."unique_string" = u."fullname"
   AND uc."value_numeric" = u."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'fullname'
   AND uc."value_string" = u."fullname";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'website'
   AND uc."value_string" = u."website";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'aboutme'
   AND uc."value_string" = u."aboutme";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'location'
   AND uc."value_string" = u."location";

DELETE FROM "classify"."unclassified" uc
 USING "classify"."users" u
 WHERE uc."_key" = 'user:' || u."uid"
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'birthday'
   AND ((u."birthday" IS NULL AND uc."value_string" = '')
    OR u."birthday" = "classify"."get_hash_date"('user:' || u."uid", 'birthday'));

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = 'globsl'
   AND uc."type" = 'hash'
   AND uc."unique_string" = 'nextUid'
   AND uc."value_string" = currval('classify.users_uid_seq')::TEXT;
