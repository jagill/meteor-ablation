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
        $(".removeFeedButton").removeClass("hidden")
        return "active"
      else
        return ""

    Template.feeds.selectedRecent = ->
      selectedId = Session.get "selectedFeedId"
      if(!selectedId)
        return "active"
      else
        return ""

    Template.feeds.events
      "click .feedLink": ->
        Session.set "selectedFeedId", @._id
        return false

      "click .recentLink": ->
        Session.set "selectedFeedId", null
        return false

      "click .feedButton": ->
        feedUrl = $("#addFeedBox").val()
        console.log "feed button clicked"
        Meteor.call "addFeed", feedUrl, (error, feedId) ->
          $('#addFeedModal').modal('hide')
          return console.error "Error in addFeed:", error if error
          console.log "Returned from addFeed with id", feedId
          Session.set 'selectedFeedId', feedId
          Session.set 'subscribeHack', Meteor.uuid()
        return false

    Template.feeds.rendered = =>

      readFileAsText = (file, callback)->
        reader = new FileReader
        reader.readAsText(file)
        reader.onload = (event)->
          $('#importFeedModal').modal('hide')
          callback(event.target.result)
        reader.onerror = ->
          document.getElementById('file-content').innerHTML = 'Unable to read ' + file.fileName

      document.getElementById("uploadFile").onchange = ->
        readFileAsText @files[0], (result)->
#          console.log "XML", result
          parser=new DOMParser()
          xmlDoc=parser.parseFromString(result,"text/xml")
          theResult = xmlDoc
          crawlTree = (tree, callback)->
            for child in tree.children()
              if $(child).children().length > 0
                crawlTree $(child), callback
              else if $(child).attr("xmlUrl")
                callback $(child).attr("xmlUrl"), $(child).attr("title")
                
          crawlTree $(theResult), (xmlUrl, title)->
            Meteor.call "addFeed", xmlUrl, title
            Session.set 'subscribeHack', Meteor.uuid()
            

    Template.articles.feedTitle = ->
      feed = Feeds.findOne Session.get "selectedFeedId"
      return feed.title if feed
      return "Recent Posts"

    Template.articles.events
      "click .removeFeedButton": ->
        console.log "remove feed button clicked"
        feed = Feeds.findOne Session.get "selectedFeedId"
        throw new Meteor.Error(401, 'No feed currently selected') unless feed
        Meteor.call "removeFeed", feed.url, (error) ->
          return console.error "Error in addFeed:", error if error
          console.log "Returned from removeFeed"
          Session.set 'selectedFeedId', Feeds.findOne()?._id
        return false

      "click .read-btn": (event) ->
        console.log event
        elId = event.target.id
        console.log "Clicked element #{elId}"
        postId = elId.split('_')[1]
        userInfoId = UserInfos.findOne(userId:Meteor.userId())?._id
        console.log "Found userInfoId #{userInfoId} for userId #{Meteor.userId()}"
        return unless userInfoId
        UserInfos.update userInfoId, {$push: {readPosts:postId}}


      "click .article-item-read .read-btn": (event) ->
        console.log event
        elId = event.target.id
        console.log "Clicked element #{elId}"
        postId = elId.split('_')[1]
        userInfoId = UserInfos.findOne(userId:Meteor.userId())?._id
        console.log "Found userInfoId #{userInfoId} for userId #{Meteor.userId()}"
        return unless userInfoId
        UserInfos.update userInfoId, {$pull: {readPosts:postId}}


    Template.articles.posts = ->
      if Session.get("selectedFeedId")
        Posts.find feedId: Session.get("selectedFeedId")
      else
        Posts.find()

    Template.articles.isRead = (postId) ->
      readPosts = UserInfos.findOne(userId:Meteor.userId())?.readPosts || []
      postId in readPosts

    Template.articles.hasFeeds = ->
      return Feeds.findOne()?


  startup: ->
    @initStickyNav()
    @initScrollingDetection()


  initScrollingDetection: () ->
    #todo mark as read as scrolled

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
  window.MABL.startup()
)
