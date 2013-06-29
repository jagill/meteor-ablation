Meteor.startup ->
  unless UserInfos.findOne()
    UserInfos.insert name: "Zanedev", feeds: [1,2,3]
    techCrunchId = Feeds.insert title: "TechCrunch"
    newYorkTimesId = Feeds.insert title: "New York Times"
    hackerNewsNewsId = Feeds.insert title: "Hacker News News"
    Posts.insert {feedId: newYorkTimesId, title: "Snowden Escapes", body: "He's gotten away!"}
    Posts.insert {feedId: newYorkTimesId, title: "Snowden Captured", body: "Uhoh!"}
    Posts.insert {feedId: hackerNewsNewsId, title: "New Groundbreaking Startup!", body: "Uhoh!"}
    Posts.insert {feedId: techCrunchId, title: "Meteor Strikes Again", body: "Even more powerful"}
