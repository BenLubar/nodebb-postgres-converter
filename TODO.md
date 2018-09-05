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
- [X] `/chat:room:[0-9]+/`
- [ ] `/confirm:[0-9a-f-]+/`
- [ ] `/diff:[0-9]+.[0-9]+/`
- [X] `/event:[0-9]+/`
- [ ] `/flag:[0-9]+/`
- [X] `/group:[^:]+/`
- [ ] `/group:cid:[0-9]+:privileges:(groups:)?(chat|find|moderate|posts:(delete|downvote|edit|history|view_deleted|upvote)|read|search:(content|tags|users)|signature|topics:(create|delete|read|reply|tag)|upload:post:(image|file))/`
- [X] `/message:[0-9]+/`
- [X] `/notifications:%/`
- [X] `/post:[0-9]+/`
- [ ] `/post:queue:reply-[0-9]+/`
- [ ] `/registration:queue:name:[^:]+/`
- [ ] `/rewards:id:[0-9]+:rewards/`
- [ ] `/rewards:id:[0-9]+/`
- [X] `/settings:[^:]+/`
- [X] `/topic:[0-9]+/`
- [X] `/uid:[0-9]+:sessionUUID:sessionId/`
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
- [X] `events:time`
- [ ] `flags:datetime`
- [ ] `flags:hash`
- [X] `fullname:uid`
- [X] `groups:createtime`
- [X] `groups:visible:createtime`
- [X] `groups:visible:memberCount`
- [X] `groups:visible:name`
- [X] `ip:recent`
- [ ] `navigation:enabled`
- [X] `notifications`
- [ ] `plugins:active`
- [ ] `post:queue`
- [ ] `posts:flagged`
- [ ] `posts:flags:count`
- [X] `posts:pid`
- [X] `posts:votes`
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
- [X] `users:banned:expire`
- [X] `users:banned`
- [ ] `users:flags`
- [X] `users:joindate`
- [ ] `users:notvalidated`
- [X] `users:online`
- [X] `users:postcount`
- [X] `users:reputation`
- [X] `userslug:uid`
- [X] `/analytics:pageviews:byCid:[0-9]+/`
- [X] `/analytics:posts:byCid:[0-9]+/`
- [X] `/analytics:topics:byCid:[0-9]+/`
- [X] `/banned:[0-9]+:reasons/`
- [X] `/chat:room:[0-9]+:uids/`
- [X] `/cid:[0-9]+:children/`
- [ ] `/cid:[0-9]+:ignorers/`
- [X] `/cid:[0-9]+:pids/`
- [ ] `/cid:[0-9]+:recent_tids/`
- [ ] `/cid:[0-9]+:subscribed:uids/`
- [X] `/cid:[0-9]+:tids:lastposttime/`
- [ ] `/cid:[0-9]+:tids:pinned/`
- [X] `/cid:[0-9]+:tids:posts/`
- [X] `/cid:[0-9]+:tids:votes/`
- [X] `/cid:[0-9]+:tids/`
- [X] `/cid:[0-9]+:uid:[0-9]+:tids/`
- [ ] `/flag:[0-9]+:history/`
- [ ] `/flag:[0-9]+:notes/`
- [ ] `/flags:byAssignee:(undefined|[0-9]*)/`
- [ ] `/flags:byCid:[0-9]+/`
- [ ] `/flags:byPid:[0-9]+/`
- [ ] `/flags:byReporter:[0-9]+/`
- [ ] `/flags:byState:(open|resolved|rejected|wip)/`
- [ ] `/flags:byTargetUid:[0-9]+/`
- [ ] `/flags:byType:(post|user)/`
- [X] `/followers:[0-9]+/`
- [X] `/following:[0-9]+/`
- [X] `/group:[^:]+:member:pids/`
- [X] `/group:[^:]+:members/`
- [ ] `/group:cid:[0-9]+:privileges:(groups:)?(chat|find|moderate|posts:(delete|downvote|edit|history|view_deleted|upvote)|read|search:(content|tags|users)|signature|topics:(create|delete|read|reply|tag)|upload:post:(image|file)):members/`
- [X] `/ip:(::ffff:)?[0-9]+.[0-9]+.[0-9]+.[0-9]+:uid/`
- [ ] `/pid:[0-9]+:flag:uid:reason/`
- [ ] `/pid:[0-9]+:flag:uids/`
- [X] `/pid:[0-9]+:replies/`
- [ ] `/post:[0-9]+:uploads/`
- [ ] `/tag:%:topics/`
- [X] `/tid:[0-9]+:bookmarks/`
- [X] `/tid:[0-9]+:posters/`
- [X] `/tid:[0-9]+:posts:votes/`
- [X] `/tid:[0-9]+:posts/`
- [X] `/uid:[0-9]+:bans/`
- [ ] `/uid:[0-9]+:blocked_uids/`
- [X] `/uid:[0-9]+:bookmarks/`
- [X] `/uid:[0-9]+:chat:room:[0-9]+:mids/`
- [ ] `/uid:[0-9]+:chat:rooms:unread/`
- [ ] `/uid:[0-9]+:chat:rooms/`
- [X] `/uid:[0-9]+:downvote/`
- [ ] `/uid:[0-9]+:flag:pids/`
- [ ] `/uid:[0-9]+:followed_tids/`
- [ ] `/uid:[0-9]+:ignored_tids/`
- [ ] `/uid:[0-9]+:ignored:cids/`
- [X] `/uid:[0-9]+:ip/`
- [X] `/uid:[0-9]+:moderation:notes/`
- [X] `/uid:[0-9]+:notifications:read/`
- [X] `/uid:[0-9]+:notifications:unread/`
- [X] `/uid:[0-9]+:posts:votes/`
- [X] `/uid:[0-9]+:posts/`
- [ ] `/uid:[0-9]+:rewards/`
- [X] `/uid:[0-9]+:sessions/`
- [ ] `/uid:[0-9]+:tids_read/`
- [ ] `/uid:[0-9]+:tids_unread/`
- [X] `/uid:[0-9]+:topics/`
- [ ] `/uid:[0-9]+:uploads/`
- [X] `/uid:[0-9]+:upvote/`
- [ ] `/upload:[0-9a-f]+:pids/`
- [X] `/user:[0-9]+:emails/`
- [X] `/user:[0-9]+:usernames/`

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
- [X] `/pid:[0-9]+:downvote/`
- [X] `/pid:[0-9]+:upvote/`
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

- [X] `/pid:[0-9]+:postRevisions/`
- [X] `/tdwtf-post-cache:[0-9]+/`

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
- [X] `/pid:[0-9]+:revisions/` (deprecated)
