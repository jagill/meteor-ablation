Meteor.startup ->
  Meteor.subscribe 'userInfos'
  Meteor.subscribe 'feeds'
  Deps.autorun ->
    Meteor.subscribe 'posts', Session.get 'selectedFeedId'
