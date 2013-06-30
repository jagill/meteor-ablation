Meteor.startup ->
  Deps.autorun ->
    Meteor.subscribe 'userInfos'
  Deps.autorun ->
    return unless Meteor.userId()
    userInfo = UserInfos.findOne(userId:Meteor.userId())
    Meteor.subscribe 'feeds', userInfo?.feeds
  Deps.autorun ->
    Meteor.subscribe 'posts', Session.get 'selectedFeedId'
  Deps.autorun ->
    return unless Meteor.userId()
    userInfo = UserInfos.findOne(userId:Meteor.userId())
    Meteor.subscribe 'recentPosts', userInfo?.feeds
