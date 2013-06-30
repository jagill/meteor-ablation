Meteor.startup ->
  Deps.autorun ->
    Meteor.subscribe 'userInfos'
  Deps.autorun ->
    Meteor.subscribe 'feeds', Session.get 'subscribeHack'
  Deps.autorun ->
    Meteor.subscribe 'posts', Session.get 'selectedFeedId'
  Deps.autorun ->
    Meteor.subscribe 'recentPosts'
