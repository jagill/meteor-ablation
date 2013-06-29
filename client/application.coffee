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

  start: ->
    console.log "starting app"

}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.start();
)