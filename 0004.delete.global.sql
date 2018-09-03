DELETE FROM "classify"."unclassified" uc
 USING "classify"."schemaDate" sd
 WHERE uc."_key" = 'schemaDate'
   AND uc."type" = 'string'
   AND uc."value_string" = sd."schemaDate";

DELETE FROM "classify"."unclassified" uc
 WHERE uc."_key" = 'global'
   AND uc."type" = 'hash'
   AND uc."unique_string" IN (
           -- importer rubbish
           'bookmarkCount',
           'categoryCount',
           'groupCount',
           'nextBid',
           'nextGid',
           'nextVid',
           'voteCount',

           -- manually-maintained statistics
           'postCount',
           'topicCount',
           'uniqueIPCount'
           'userCount',

           -- converted to sequences
           'nextCid',
           'nextPid',
           'nextTid',
           'nextUid'
       );
