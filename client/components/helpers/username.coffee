Template.registerHelper 'usernameFromId', (userId) ->
  Meteor.users.findOne(userId)?.username
