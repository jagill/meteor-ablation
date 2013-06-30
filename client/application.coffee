window.MABL = {
  init: ->
    Template.feeds.feeds = ->
      Feeds.find()

    Template.feeds.selected = ->
      if @._id == Session.get "selectedFeedId"
        return "active"
      else
        return ""

    Template.feeds.events
      "click .feedLink": ->
        Session.set "selectedFeedId", @._id
        return false

    Template.topArticle.feedTitle = ->
      feed = Feeds.findOne Session.get "selectedFeedId"
      return feed.title if feed
      return "Select a feed on the left"

    Template.topArticle.posts = ->
      Posts.find feedId: Session.get("selectedFeedId")

  start: ->
    console.log "starting app"

}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.start();
)