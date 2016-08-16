Meteor.methods
  checkUsername: (username) ->
    # If our user is already in Meteor.users, cool. If not, query LDAP and insert into Meteor.users.
    user = Meteor.users.findOne {username: username.toLowerCase()}
    if user?
      return user._id
    else
      client = LDAP.createClient Meteor.settings.ldap.serverUrl
      LDAP.bind client, Meteor.settings.ldapDummy.username, Meteor.settings.ldapDummy.password
      userObj = LDAP.search client, username
      unless userObj?
        return false
      else
        user = Meteor.users.findOne {username: username.toLowerCase()}
        if user
          userId = user._id
          Meteor.users.update(userId, {$set: userObj})
        else
          userId = Meteor.users.insert(userObj)
        return userId

  checkPassword: (username, password) ->
    # Check a username and password against LDAP without Meteor login.
    client = LDAP.createClient Meteor.settings.ldap.serverUrl
    LDAP.bind client, username, password
    return LDAP.search(client, username)?

 
  deleteItem: (itemId) ->
    if Roles.userIsInRole @userId, 'admin'
      Inventory.remove(itemId)
      Changelog.remove { itemtId: itemId }
      Checkouts.remove { assetId: itemId }

  cancelReservation: (resId) ->
    if Roles.userIsInRole @userId, 'admin'
      checkout = Checkouts.findOne(resId)
      user = Meteor.users.findOne(checkout.assignedTo)
      item = Inventory.findOne(checkout.assetId)
      console.log "User #{@userId} cancelling reservation: #{JSON.stringify(checkout)} for #{user.username}"
      Checkouts.remove { _id: resId }
      scheduleMail
        email: user.mail
        subject: "Your checkout of item #{item?.name} has been cancelled."
        html: "Your checkout of item #{item?.name} for #{moment(checkout.schedule.timeReserved).format('LL')} has been cancelled.
        If you feel this is in error, please submit a help request."
        date: new Date()
