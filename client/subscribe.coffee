Meteor.startup ->
  Deps.autorun ->
    Meteor.subscribe 'userInfos'
  Deps.autorun ->
    Meteor.subscribe 'feeds'
  Deps.autorun ->
    Meteor.subscribe 'posts', Session.get 'selectedFeedId'
  Deps.autorun ->
    Meteor.subscribe 'recentPosts'
