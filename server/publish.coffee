Meteor.publish 'userInfos', ->
  return UserInfos.find userId:@userId

Meteor.publish 'feeds', ->
  return unless @userId
  userInfo = UserInfos.findOne userId:@userId
  return unless userInfo
  return Feeds.find _id: {$in: userInfo.feeds}

Meteor.publish 'posts', (feedId) ->
  return unless feedId
  readPosts = UserInfos.findOne(userId:@userId)?.readPosts || []
  return Posts.find {feedId:feedId, _id: {$nin: readPosts}}

Meteor.publish 'recentPosts', ->
  return unless @userId
  userInfo = UserInfos.findOne userId:@userId
  return unless userInfo
  readPosts = UserInfos.findOne(userId:@userId)?.readPosts || []
  return Posts.find {feedId: {$in: userInfo.feeds}, _id: {$nin: readPosts}}, {sort: {published_at: -1}, limit: 5}

UserInfos.allow
  insert: (userId, doc) ->
    return userId == doc.userId

  update: (userId, doc, fieldNames, modifier) ->
    return userId == doc.userId
