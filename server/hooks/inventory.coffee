Inventory.before.insert (userId, doc) ->
  doc.enteredAtTimestamp = new Date()
  doc.enteredByUserId = userId
  Buildings.upsert { building: doc.building }, { $set: { lastUse: new Date() } }
  Models.upsert { model: doc.model }, { $set: { lastUse: new Date() } }

Inventory.before.update (userId, doc, fieldNames, modifier, options) ->
  _.each fieldNames, (fn) ->
    if fn is 'attachments'
      otherId = modifier.$addToSet?.attachments.fileId || modifier.$pull?.attachments.fileId
      filename = FileRegistry.findOne(otherId)?.filename
      Changelog.insert
        itemId: doc._id
        field: 'attachments'
        type: 'attachment'
        otherId: otherId
        oldValue: if modifier.$pull? then filename
        newValue: if modifier.$addToSet? then filename
        timestamp: new Date()
        userId: userId
        username: Meteor.users.findOne(userId)?.username
    else
      if _.isString doc[fn]
        oldValue = escape(doc[fn])
        newValue = escape(modifier.$set[fn])
      unless oldValue is newValue
        Changelog.insert
          itemId: doc._id
          field: fn
          type: 'field'
          oldValue: oldValue
          newValue: newValue
          timestamp: new Date()
          userId: userId
          username: Meteor.users.findOne(userId)?.username

