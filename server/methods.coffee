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
      Changelog.remove { itemId: itemId }
      Checkouts.remove { assetId: itemId }

  recordItemDelivery: (assetId, username) ->
    if Roles.userIsInRole @userId, 'admin'
      Deliveries.insert {
        assetId: assetId
        deliveredByUserId: @userId
        deliveredTo: username
        deliveredToUserId: Meteor.users.findOne({username: username})?._id || null
        timestamp: new Date()
      }

      Inventory.update assetId, { $set: { delivered: true } }
