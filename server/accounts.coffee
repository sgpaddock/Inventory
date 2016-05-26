Accounts.onLogin (info) ->
  if Meteor.settings.permissions

    roles = Roles.getRolesForUser info.user._id

    if info.user.username in Meteor.settings.permissions.admins
      Roles.addUsersToRoles info.user._id, 'admin', Roles.GLOBAL_GROUP
    else if 'admin' in roles
      Roles.removeUsersFromRoles info.user._id, 'admin', Roles.GLOBAL_GROUP
    
    # Currently unused - hopefully for future Inventory functionality
    for d,v of Meteor.settings.permissions.departmentManagers
      if info.user.username in v
        console.log "#{info.user.username} DM for group #{d}"
        Roles.addUsersToRoles info.user._id, 'departmentManager', d

    Roles.addUsersToRoles info.user._id, 'user', info.user.department
