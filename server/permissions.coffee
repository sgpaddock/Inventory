Meteor.users.allow
  insert: -> false
  update: (userId, doc, fields, modifier) ->
    if doc._id is userId and _.intersection(['_id', 'department', 'displayName', 'employeeNumber', 'givenName', 'memberOf', 'services', 'status', 'title', 'username'], fields).length is 0
      return true
    else
      return false
  remove: -> false
