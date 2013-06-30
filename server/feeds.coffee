rssparser = Meteor.require('rssparser')

Meteor.methods
  addFeed: (url, userId) ->
    #response: {feed:, articles:}
    rssparser.parseURL url, {}, (error, response) ->
      throw new Meteor.Error(500, error.message) if error
      articles = response.items
      delete response.items
      #console.log "Feed:", response
      #console.log "Article count:", articles.length
      #console.log "First article:", articles[0] if articles
      response.url = url
      feedId = Feeds.insert response
      for article in articles
        article.feedId = feedId
        Posts.insert article
      userInfo = UserInfos.findOne userId: this.userId
      if userInfo
        UserInfos.update {userId: this.userId}, {$push: {feeds: feedId}}
      else
        userInfo = {userId: this.userId, feeds: [feedId]}
        UserInfo.insert userInfo

      #userInfos = .userId

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
