Meteor.users.allow
  insert: -> false
  update: (userId, doc, fields, modifier) ->
    if doc._id is userId and _.intersection(['_id', 'department', 'displayName', 'employeeNumber', 'givenName', 'memberOf', 'services', 'status', 'title', 'username', 'roles'], fields).length is 0
      return true
    else
      return false
  remove: -> false

Inventory.allow
  insert: -> true
  update: -> true
  remove: -> false


Checkouts.allow
  insert: (userId, doc) -> !(doc.approval) or doc.approval?.approverId is (userId or null)
  update: (userId, doc, fields, modifier) -> true
  remove: -> false
