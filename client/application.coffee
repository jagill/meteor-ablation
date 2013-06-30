window.MABL = {
  seedDatabase: ->
    console.log "seeding the database"
    Meteor.call "addFeed", "http://feeds.feedburner.com/AVc"
    Meteor.call "addFeed", "http://biritemarket.com/feed/"
    Meteor.call "addFeed", "http://bootiemashup.com/blog/feed"
    Meteor.call "addFeed", "http://blog.getbootstrap.com/feed.xml"

  init: ->
    addFeedToUser = (value) ->
      unless Meteor.userId()
        console.error "NO USER FOUND"
        return
      userInfo = UserInfos.findOne(userId:Meteor.userId())
      if userInfo
        UserInfos.update userInfo._id, {$push: {feeds:value}}
      else
        userInfo = {userId:Meteor.userId(), feeds:[value], readPosts:[]}
        UserInfos.insert userInfo

    Template.feedNotifications.helpers
      topNotification: ->
        Notifications.findOne {}, {sort: {timestamp: -1}}

      notifications: ->
        Notifications.find {}, {sort: {timestamp: -1}, limit:10}

    Template.feeds.feeds = ->
      Feeds.find()

    Template.feeds.selected = ->
      if @._id == Session.get "selectedFeedId"
        return "active"
      else
        return ""

    Template.feeds.selectedRecent = ->
      feedId = Session.get 'selectedFeedId'
      if feedId
        return ""
      else
        return "active"

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
          #feedId is null if we get a 40X error code
          if feedId
            Session.set 'selectedFeedId', feedId
            addFeedToUser feedId
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

      document.getElementById("uploadFile")?.onchange = ->
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
            Meteor.call "addFeed", xmlUrl, title, (error, feedId) ->
              console.log "ADDING FEED TO USER", feedId
              addFeedToUser feedId if feedId
            
    Template.articles.feedTitle = ->
      feed = Feeds.findOne Session.get "selectedFeedId"
      return feed.title if feed
      return "Recent Posts"

    Template.articles.events
      "click .removeFeedButton": ->
        console.log "remove feed button clicked"
        userInfo = UserInfos.findOne(userId:Meteor.userId())
        return unless userInfo
        feed = Feeds.findOne Session.get "selectedFeedId"
        result = confirm("Are you sure you want to delete \n"+feed.title+"?")
        return unless result
        UserInfos.update userInfo._id, {$pull: {feeds: Session.get "selectedFeedId"}}
        event.stopPropagation()
        return false

      "click .read-btn": (event) ->
        elId = event.target.id
        postId = elId.split('_')[1]
        userInfoId = UserInfos.findOne(userId:Meteor.userId())?._id
        console.log "Found userInfoId #{userInfoId} for userId #{Meteor.userId()}"
        return unless userInfoId
        UserInfos.update userInfoId, {$push: {readPosts:postId}}
        post = Posts.findOne postId
        message = "#{Meteor.user().profile.name} has read #{post.title}"
        Notifications.insert timestamp:Date.now(), message:message


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

    Template.articles.hasActiveFeed = ->
      return Session.get 'selectedFeedId'

  startup: ->
    @initStickyNav()
    @initScrollingDetection()


  initScrollingDetection: () ->
    #todo mark as read as scrolled

  initStickyNav: () ->
    fixed = false
    navBar = $(".sidebar-nav")
    threshold = (navBar.offset().top - 80)

    applyStickyNav = (e) ->
      console.log "apply sticky nav"
      belowThreshold = $(window).scrollTop() >= threshold
      if not fixed and belowThreshold and navBar.outerHeight() < $(window).height()
        resetNavWidth()
        navBar.addClass "fixed"
        fixed = true
      else if fixed and not belowThreshold
        navBar.css "width":"auto"
        navBar.removeClass "fixed"
        fixed = false

    resetNavWidth = (e) ->
      navBar.css "width":($("#helperwidthdiv").width() - 40)


    $(window).scroll applyStickyNav
    $(window).resize resetNavWidth
}

window.MABL.init()

Meteor.startup( () ->
  window.MABL.startup()
)
