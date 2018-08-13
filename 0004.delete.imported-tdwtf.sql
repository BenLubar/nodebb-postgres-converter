-- useless
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = '_imported:_bookmarks'
   AND uc."type" = 'zset'
   AND uc."unique_string" SIMILAR TO '[1-9][0-9]*';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_categories" ic
 WHERE uc."_key" = '_imported:_categories'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ic."discourse_id"::TEXT
   AND uc."value_numeric" = ic."cid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_categories" ic
 WHERE uc."_key" = '_telligent:_categories'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ic."telligent_id"::TEXT
   AND uc."value_numeric" = ic."discourse_id"::NUMERIC;

-- useless
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = '_imported:_favourites'
   AND uc."type" = 'zset'
   AND uc."unique_string" SIMILAR TO '[1-9][0-9]*';

-- useless
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = '_imported:_groups'
   AND uc."type" = 'zset'
   AND uc."unique_string" SIMILAR TO '[1-9][0-9]*';

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_messages" im
 WHERE uc."_key" = '_imported:_messages'
   AND uc."type" = 'zset'
   AND uc."unique_string" = im."discourse_id"::TEXT
   AND uc."value_numeric" = im."mid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_posts" ip
 WHERE uc."_key" = '_imported:_posts'
   AND uc."type" = 'zset'
   AND (uc."unique_string" = (ip."discourse_id" * 2 + 1)::TEXT
    OR  uc."unique_string" = (ip."telligent_id" * 2)::TEXT)
   AND uc."value_numeric" = ip."pid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_rooms" ir
 WHERE uc."_key" = '_imported:_rooms'
   AND uc."type" = 'zset'
   AND uc."unique_string" = ir."discourse_id"::TEXT
   AND uc."value_numeric" = ir."roomId"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_topics" it
 WHERE uc."_key" = '_imported:_topics'
   AND uc."type" = 'zset'
   AND (uc."unique_string" = (it."discourse_id" * 2 + 1)::TEXT
    OR  uc."unique_string" = (it."telligent_id" * 2)::TEXT)
   AND uc."value_numeric" = it."tid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_users" iu
 WHERE uc."_key" = '_imported:_users'
   AND uc."type" = 'zset'
   AND uc."unique_string" = iu."discourse_id"::TEXT
   AND uc."value_numeric" = iu."uid"::NUMERIC;

DELETE FROM "classify"."unclassified" uc
 USING "classify"."imported_users" iu
 WHERE uc."_key" = '_telligent:_users'
   AND uc."type" = 'zset'
   AND uc."unique_string" = iu."telligent_id"::TEXT
   AND uc."value_numeric" = iu."discourse_id"::NUMERIC;

-- useless
DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = '_imported:_votes'
   AND uc."type" = 'zset'
   AND uc."unique_string" SIMILAR TO '[1-9][0-9]*';
