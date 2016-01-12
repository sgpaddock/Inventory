Template.username.helpers
  username: -> Meteor.users.findOne(@valueOf()).username
