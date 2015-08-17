Inventory.before.insert (userId, doc) ->
  doc.enteredAtTimestamp = new Date()
  doc.enteredByUserId = userId
