
###
# feeds: []
# postsRead: []
###
@UserInfos = new Meteor.Collection 'userInfos'

###
# url:
# posts: []
###
@Feeds = new Meteor.Collection 'feeds'

###
# title:
# blurb:
# body:
###
@Posts = new Meteor.Collection 'posts'

###
# timestamp:
# message:
###
@Notifications = new Meteor.Collection 'notifications'
