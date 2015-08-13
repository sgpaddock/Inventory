Template.userDashboard.helpers
  notificationSettings: ->
    Meteor.user()?.notificationSettings
  saved: ->
    Session.get 'saved'

