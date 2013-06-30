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
            $('#addFeedModal').modal('hide')
            return console.error "Error in addFeed:", error if error
          console.log "Returned from addFeed"
        return false

    Template.feeds.rendered = ->
      readFileAsText = (file, callback)->
        reader = new FileReader
        reader.readAsText(file);
        reader.onload = (event)->
          $('#importFeedModal').modal('hide')
          callback(event.target.result)
        reader.onerror = ->
          document.getElementById('file-content').innerHTML = 'Unable to read ' + file.fileName;

      document.getElementById("uploadFile").onchange = ->
        readFileAsText @files[0], (result)->
#          console.log "XML", result
          parser=new DOMParser();
          xmlDoc=parser.parseFromString(result,"text/xml")
          window.theResult = xmlDoc
          feedObjs = $($(theResult).children().children()[1]).children()
          for obj in feedObjs
            Meteor.call "addFeed", $(obj).attr("xmlUrl"), $(obj).attr("title")

    Template.articles.feedTitle = ->
      feed = Feeds.findOne Session.get "selectedFeedId"
      return feed.title if feed
      return "Recent Posts"

    Template.articles.events
      "click .removeFeedButton": ->
        console.log "remove feed button clicked"
        feed = Feeds.findOne Session.get "selectedFeedId"
        Meteor.call "removeFeed", feed.url, (error) ->
            return console.error "Error in addFeed:", error if error
          console.log "Returned from addFeed"
        return false

    Template.articles.posts = ->
      if Session.get("selectedFeedId")
        Posts.find feedId: Session.get("selectedFeedId")
      else
        Posts.find()

  startup: ->
    @initStickyNav()
    @initScrollingDetection()

  initScrollingDetection: () ->


  initStickyNav: () ->
    fixed = false
    navBar = $(".sidebar-nav")
    threshold = navBar.offset().top
    $(window).scroll ->
      belowThreshold = $(window).scrollTop() >= threshold
      if not fixed and belowThreshold and navBar.outerHeight() < $(window).height()
        navBar.addClass "fixed"
        fixed = true
      else if fixed and not belowThreshold
        navBar.removeClass "fixed"
        fixed = false
}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.startup();
)
