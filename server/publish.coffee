Meteor.publish 'userInfos', ->
  return UserInfos.find userId:@userId

Meteor.publish 'feeds', ->
  return unless @userId
  userInfo = UserInfos.findOne userId:@userId
  return unless userInfo
  return Feeds.find _id: {$in: userInfo.feeds}

Meteor.publish 'posts', (feedId) ->
  return unless feedId
  return Posts.find feedId:feedId

Meteor.publish 'recentPosts', ->
  return unless @userId
  return unless userInfo
  userInfo = UserInfos.findOne userId:@userId
  return Posts.find {feedId: {$in: userInfo.feeds}}, {sort: {published_at: -1}, limit: 5}

UserInfos.allow
  update: (userId, doc, fieldNames, modifier) ->
    return userId == doc.userId
