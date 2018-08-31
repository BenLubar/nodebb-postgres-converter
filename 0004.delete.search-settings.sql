DELETE FROM "unclassified" uc
 WHERE uc."_key" = 'nodebb-plugin-dbsearch'
   AND uc."type" = 'hash'
   AND uc."unique_string" IN (
           -- converted to search_settings
           'indexLanguage',
           'postLimit',
           'topicLimit',

           -- index is no longer manually-maintained
           'postsIndexed',
           'topicsIndexed',
           'working'
       );
