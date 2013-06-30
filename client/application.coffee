window.MABL = {
  seedDatabase: ->
    console.log "seeding the database"
    Meteor.call "addFeed", "http://feeds.feedburner.com/AVc", Meteor.userId()
    Meteor.call "addFeed", "http://biritemarket.com/feed/", Meteor.userId()
    Meteor.call "addFeed", "http://bootiemashup.com/blog/feed", Meteor.userId()
    Meteor.call "addFeed", "http://blog.getbootstrap.com/feed.xml", Meteor.userId()

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

      "click .feedButton": ->
        feedUrl = $("#addFeedBox").val()
        console.log "feed button clicked"
        Meteor.call "addFeed", feedUrl, (error) ->
          return console.error "Error in addFeed:", error if error
          console.log "Returned from addFeed"

        return false

    Template.topArticle.feedTitle = ->
      feed = Feeds.findOne Session.get "selectedFeedId"
      return feed.title if feed
      return "Select a feed on the left"

    Template.topArticle.posts = ->
      Posts.find feedId: Session.get("selectedFeedId")

  startup: ->
    console.log "starting up"


}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.startup();
)
