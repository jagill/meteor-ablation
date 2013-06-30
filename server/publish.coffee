Meteor.publish 'userInfos', ->
  return UserInfos.find userId:@userId

Meteor.publish 'feeds', ->
  userInfo = UserInfos.findOne userId:@userId
  return Feeds.find _id: {$in: userInfo.feeds}

Meteor.publish 'posts', (feedId) ->
  return unless feedId
  return Posts.find feedId:feedId

