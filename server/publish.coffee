Meteor.publish 'userData', ->
  Meteor.users.find {_id: @userId}

Meteor.publish 'allUserData', ->
  Meteor.users.find {}, {fields: {'_id': 1, 'username': 1, 'mail': 1, 'displayName': 1, 'department': 1, 'physicalDeliveryOfficeName': 1, 'status.online': 1, 'status.idle': 1}}

AutoTable.publish 'inventory', ->
  # Permissions go here
  Inventory
, null, true

AutoTable.publish 'checkouts', Inventory, { checkout: true }, true

Meteor.publish 'files', -> FileRegistry.find()

Meteor.publishComposite 'inventory', (filter) ->
  [itemSet, facets] = Inventory.findWithFacets filter
  itemSet = _.pluck itemSet.fetch(), '_id'
  {
    find: ->
      Inventory.find { _id: { $in: itemSet } }
    children: [
      {
        find: (item) ->
          ids = _.pluck item.attachments, 'fileId' # not reactive
          FileRegistry.find { _id: { $in: ids } }
      }
      {
        find: -> facets
      }
    ]
  }

Meteor.publishComposite 'newInventory', (filter, time) ->
  if not filter then filter = {}
  _.extend filter, { enteredAtTimestamp: { $gt: time } }
  {
    find: ->
      Inventory.find filter
    children: [
      {
        find: (item) ->
          ids = _.pluck item.attachments, 'fileId'
          FileRegistry.find { _id: { $in: ids } }
      }
    ]
  }


Meteor.publishComposite 'inventorySet', (set) ->
  if not set then set = []
  {
    find: ->
      Inventory.find { _id: { $in: set } }
    children: [
      {
        find: (item) ->
          ids = _.pluck item.attachments, 'fileId'
          FileRegistry.find { _id: { $in: ids } }
      }
    ]
  }
