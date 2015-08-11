Inventory.before.insert (userId, doc) ->
  doc.enteredByUserId = userId
