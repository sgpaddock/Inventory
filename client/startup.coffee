Tracker.autorun ->
  if Meteor.userId()
    Cookie.set 'meteor_login_token', Accounts._storedLoginToken()
    Cookie.set 'meteor_login_token_expires', Accounts._storedLoginTokenExpires()
  else
    Cookie.remove 'meteor_login_token'
    Cookie.remove 'meteor_login_token_expires'
