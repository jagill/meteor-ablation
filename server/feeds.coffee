rssparser = Meteor.require('rssparser')

addFeedToUser = (feedId, userId) ->
  console.log "Adding feed #{feedId} to user #{userId}"
  if UserInfos.findOne(userId: userId)
    console.log "Found existing userInfo"
    UserInfos.update {userId: userId}, {$push: {feeds: feedId}}
  else
    console.log "Making new userInfo"
    UserInfos.insert {userId: userId, feeds: [feedId]}

Meteor.setInterval ->
  console.log "Refreshing feeds"
  Meteor.call 'refreshFeeds'
, 10*1000

Meteor.methods
  addFeed: (url, title) ->
    console.log "Adding feed for #{url} for userId #{@userId}"
    throw new Meteor.Error(401, 'Must be logged in to add a feed') unless @userId
    feed = Feeds.findOne url:url
    if feed
      console.log "Found existing feed for #{url}"
      addFeedToUser feed._id, @userId
    else
      console.log "Getting new feed #{url}"
      Meteor.http.get url, {}, (error, response) =>
        throw new Meteor.Error(500, error.message) if error
        rssparser.parseString response.content, {}, (error, data) =>
          posts = data.items
          delete data.items
          #console.log "Feed:", data
          #console.log "Article count:", posts.length
          #console.log "First article:", posts[0] if posts
          data.url = url
          data.title = title if title
          feedId = Feeds.insert data
          addFeedToUser feedId, @userId
          for post in posts
            post.feedId = feedId
            post.feedTitle = data.title
            Posts.insert post

  refreshFeeds: ->
    Feeds.find().map (feed) ->
      Meteor.http.get feed.url, {}, (error, response) =>
        return console.error error if error
        rssparser.parseString response.content, {}, (error, data) =>
          posts = data.items
          #newUrls = _.pluck posts, 'url'
          #Posts.remove {url: {$nin: newUrls}}
          for post in posts
            post.feedId = feed._id
            post.feedTitle = feed.title
            existingPost = Posts.findOne url: post.url
            if existingPost
              Posts.update existingPost._id, post
            else
              Posts.insert post

  removeFeed: (url) ->
    throw new Meteor.Error(401, 'Must be logged in to remove a feed') unless @userId
    feed = Feeds.findOne url:url
    if feed
      console.log "Feed at #{url} exist, removing for user #{@userId}"
      Posts.remove {feedId: feed._id}

      userfeeds = UserInfos.findOne({userId: @userId}).feeds
      if(userfeeds)
        console.log "Found feeds array, removing feed #{feed._id} from it"
        index = userfeeds.indexOf feed.feedId
        userfeeds.splice index, 1
        UserInfos.update {userId: @userId}, {$set: {feeds: userfeeds}}

      Feeds.remove feed

