rssparser = Meteor.require('rssparser')

addFeedToUser = (feedId, userId) ->
  console.log "Adding feed #{feedId} to user #{userId}"
  if UserInfos.findOne(userId: userId)
    console.log "Found existing userInfo"
    UserInfos.update {userId: userId}, {$push: {feeds: feedId}}
  else
    console.log "Making new userInfo"
    UserInfos.insert {userId: userId, feeds: [feedId]}


Meteor.methods
  addFeed: (url) ->
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
          articles = data.items
          delete data.items
          #console.log "Feed:", data
          #console.log "Article count:", articles.length
          #console.log "First article:", articles[0] if articles
          data.url = url
          feedId = Feeds.insert data
          addFeedToUser feedId, @userId
          for article in articles
            article.feedId = feedId
            Posts.insert article

removeFeed: (url) ->
  feed = Feeds.findOne url:url
  if feed
    console.log "Feed at #{url} exist, removing for user #{@userId}"
    Posts.remove {feedId: feed.feedId}

    userfeeds = UserInfos.findOne({userId: @userId}).feeds
    if(userfeeds)
      console.log "Found feeds array, removing feed #{feed.feedId} from it"
      index = userfeeds.indexOf feed.feedId
      userfeeds.splice index, 1
      UserInfos.update {userId: @userId}, {$push: {feeds: userfeeds}}

    Feeds.remove feed

###
# FEED (META) DATA:
# title
# description
# link (website link)
# xmlurl (the canonical link to the feed, as specified by the feed)
# date (most recent update)
# pubdate (original published date)
# author
# language
# image (an Object containing url and title properties)
# favicon (a link to the favicon -- only provided by Atom feeds)
# copyright
# generator
# categories (an Array of Strings)
###

###
# ARTICLE DATA
# title
# description (frequently, the full article content)
# summary (frequently, an excerpt of the article content)
# link
# origlink (when FeedBurner or Pheedo puts a special tracking url in the link property, origlink contains the original link)
# date (most recent update)
# pubdate (original published date)
# author
# guid (a unique identifier for the article)
# comments (a link to the article's comments section)
# image (an Object containing url and title properties)
# categories (an Array of Strings)
# source (an Object containing url and title properties pointing to the original source for an article; see the RSS Spec for an explanation of this element)
# enclosures (an Array of Objects, each representing a podcast or other enclosure and having a url property and possibly type and length properties)
# meta (an Object containing all the feed meta properties; especially handy when using the EventEmitter interface to listen to article emissions)
###
