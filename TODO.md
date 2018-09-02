# hash

- [X] `config`
- [X] `fbid:uid`
- [X] `githubid:uid`
- [ ] `global`
- [X] `gplusid:uid`
- [X] `groupslug:groupname`
- [X] `ip-blacklist-rules`
- [ ] `lastrestart`
- [X] `nodebb-plugin-dbsearch`
- [X] `twid:uid`
- [ ] `widgets:global`
- [X] `/category:[0-9]+/`
- [ ] `/chat:room:[0-9]+/`
- [ ] `/confirm:[0-9a-f-]+/`
- [ ] `/diff:[0-9]+.[0-9]+/`
- [ ] `/event:[0-9]+/`
- [ ] `/flag:[0-9]+/`
- [X] `/group:[^:]+/`
- [ ] `/group:cid:[0-9]+:privileges:(groups:)?(chat|find|moderate|posts:(delete|downvote|edit|history|view_deleted|upvote)|read|search:(content|tags|users)|signature|topics:(create|delete|read|reply|tag)|upload:post:(image|file))/`
- [ ] `/message:[0-9]+/`
- [ ] `/notifications:%/`
- [ ] `/post:[0-9]+/`
- [ ] `/post:queue:reply-[0-9]+/`
- [ ] `/registration:queue:name:[^:]+/`
- [ ] `/rewards:id:[0-9]+:rewards/`
- [ ] `/rewards:id:[0-9]+/`
- [X] `/settings:[^:]+/`
- [X] `/topic:[0-9]+/`
- [ ] `/uid:[0-9]+:sessionUUID:sessionId/`
- [ ] `/user:[0-9]+:settings/`
- [X] `/user:[0-9]+/`
- [ ] `/widgets:[^:]+.tpl/`

# zset

- [X] `analytics:errors:404`
- [X] `analytics:errors:503`
- [X] `analytics:flags`
- [X] `analytics:pageviews`
- [X] `analytics:pageviews:month`
- [X] `analytics:posts`
- [X] `analytics:topics`
- [X] `analytics:uniquevisitors`
- [X] `categories:cid`
- [ ] `digest:day:uids`
- [ ] `digest:week:uids`
- [X] `email:sorted`
- [X] `email:uid`
- [X] `errors:404`
- [ ] `events:time`
- [ ] `flags:datetime`
- [ ] `flags:hash`
- [X] `fullname:uid`
- [X] `groups:createtime`
- [X] `groups:visible:createtime`
- [X] `groups:visible:memberCount`
- [X] `groups:visible:name`
- [X] `ip:recent`
- [ ] `navigation:enabled`
- [ ] `notifications`
- [ ] `plugins:active`
- [ ] `post:queue`
- [ ] `posts:flagged`
- [ ] `posts:flags:count`
- [ ] `posts:pid`
- [ ] `posts:votes`
- [ ] `registration:queue`
- [ ] `schemaLog`
- [ ] `tags:topic:count`
- [X] `topics:posts`
- [X] `topics:recent`
- [X] `topics:tid`
- [X] `topics:views`
- [X] `topics:votes`
- [X] `username:sorted`
- [X] `username:uid`
- [ ] `users:banned:expire`
- [ ] `users:banned`
- [ ] `users:flags`
- [X] `users:joindate`
- [ ] `users:notvalidated`
- [X] `users:online`
- [ ] `users:postcount`
- [X] `users:reputation`
- [X] `userslug:uid`
- [X] `/analytics:pageviews:byCid:[0-9]+/`
- [X] `/analytics:posts:byCid:[0-9]+/`
- [X] `/analytics:topics:byCid:[0-9]+/`
- [ ] `/banned:[0-9]+:reasons/`
- [ ] `/chat:room:[0-9]+:uids/`
- [ ] `/cid:[0-9]+:children/`
- [ ] `/cid:[0-9]+:ignorers/`
- [ ] `/cid:[0-9]+:pids/`
- [ ] `/cid:[0-9]+:recent_tids/`
- [ ] `/cid:[0-9]+:subscribed:uids/`
- [ ] `/cid:[0-9]+:tids:lastposttime/`
- [ ] `/cid:[0-9]+:tids:pinned/`
- [ ] `/cid:[0-9]+:tids:posts/`
- [ ] `/cid:[0-9]+:tids:votes/`
- [ ] `/cid:[0-9]+:tids/`
- [ ] `/cid:[0-9]+:uid:[0-9]+:tids/`
- [ ] `/flag:[0-9]+:history/`
- [ ] `/flag:[0-9]+:notes/`
- [ ] `/flags:byAssignee:(undefined|[0-9]*)/`
- [ ] `/flags:byCid:[0-9]+/`
- [ ] `/flags:byPid:[0-9]+/`
- [ ] `/flags:byReporter:[0-9]+/`
- [ ] `/flags:byState:(open|resolved|rejected|wip)/`
- [ ] `/flags:byTargetUid:[0-9]+/`
- [ ] `/flags:byType:(post|user)/`
- [ ] `/followers:[0-9]+/`
- [ ] `/following:[0-9]+/`
- [ ] `/group:[^:]+:member:pids/`
- [X] `/group:[^:]+:members/`
- [ ] `/group:cid:[0-9]+:privileges:(groups:)?(chat|find|moderate|posts:(delete|downvote|edit|history|view_deleted|upvote)|read|search:(content|tags|users)|signature|topics:(create|delete|read|reply|tag)|upload:post:(image|file)):members/`
- [X] `/ip:(::ffff:)?[0-9]+.[0-9]+.[0-9]+.[0-9]+:uid/`
- [ ] `/pid:[0-9]+:flag:uid:reason/`
- [ ] `/pid:[0-9]+:flag:uids/`
- [ ] `/pid:[0-9]+:replies/`
- [ ] `/post:[0-9]+:uploads/`
- [ ] `/tag:%:topics/`
- [ ] `/tid:[0-9]+:bookmarks/`
- [ ] `/tid:[0-9]+:posters/`
- [ ] `/tid:[0-9]+:posts:votes/`
- [ ] `/tid:[0-9]+:posts/`
- [ ] `/uid:[0-9]+:bans/`
- [ ] `/uid:[0-9]+:blocked_uids/`
- [ ] `/uid:[0-9]+:bookmarks/`
- [ ] `/uid:[0-9]+:chat:room:[0-9]+:mids/`
- [ ] `/uid:[0-9]+:chat:rooms:unread/`
- [ ] `/uid:[0-9]+:chat:rooms/`
- [ ] `/uid:[0-9]+:downvote/`
- [ ] `/uid:[0-9]+:flag:pids/`
- [ ] `/uid:[0-9]+:followed_tids/`
- [ ] `/uid:[0-9]+:ignored_tids/`
- [ ] `/uid:[0-9]+:ignored:cids/`
- [X] `/uid:[0-9]+:ip/`
- [ ] `/uid:[0-9]+:moderation:notes/`
- [ ] `/uid:[0-9]+:notifications:read/`
- [ ] `/uid:[0-9]+:notifications:unread/`
- [ ] `/uid:[0-9]+:posts:votes/`
- [ ] `/uid:[0-9]+:posts/`
- [ ] `/uid:[0-9]+:rewards/`
- [ ] `/uid:[0-9]+:sessions/`
- [ ] `/uid:[0-9]+:tids_read/`
- [ ] `/uid:[0-9]+:tids_unread/`
- [X] `/uid:[0-9]+:topics/`
- [ ] `/uid:[0-9]+:uploads/`
- [ ] `/uid:[0-9]+:upvote/`
- [ ] `/upload:[0-9a-f]+:pids/`
- [ ] `/user:[0-9]+:emails/`
- [ ] `/user:[0-9]+:usernames/`

# set

- [ ] `conditions:active`
- [ ] `rewards:list`
- [ ] `/cid:[0-9]+:read_by_uid/`
- [ ] `/condition:[^:]+:rewards/`
- [X] `/group:[^:]+:invited/`
- [X] `/group:[^:]+:owners/`
- [X] `/group:[^:]+:pending/`
- [ ] `/ignored:[0-9]+/`
- [ ] `/ignored:by:[0-9]+/`
- [ ] `/ignored:chat:[0-9]+/`
- [ ] `/pid:[0-9]+:downvote/`
- [ ] `/pid:[0-9]+:upvote/`
- [ ] `/pid:[0-9]+:users_bookmarked/`
- [ ] `/tid:[0-9]+:followers/`
- [ ] `/tid:[0-9]+:ignorers/`
- [ ] `/topic:[0-9]+:tags/`
- [ ] `/uid:[0-9]+:flagged_by/`
- [ ] `/uid:[0-9]+:tokens/`

# list

- [ ] `/post:[0-9]+:diffs/`

# string

- [X] `schemaDate`

# tdwtf-specific

## hash (tdwtf)

- [ ] `/pid:[0-9]+:postRevisions/`
- [ ] `/tdwtf-post-cache:[0-9]+/`

## zset (tdwtf)

- [X] `_imported:_bookmarks`
- [X] `_imported:_categories`
- [X] `_imported:_favourites`
- [X] `_imported:_messages`
- [X] `_imported:_posts`
- [X] `_imported:_rooms`
- [X] `_imported:_topics`
- [X] `_imported:_users`
- [X] `_imported:_votes`
- [X] `_telligent:_categories`
- [X] `_telligent:_users`
- [ ] `tdwtf-upstreams:started`
- [ ] `/pid:[0-9]+:revisions/` (deprecated)
