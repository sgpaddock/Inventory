Meteor.publish 'userData', ->
  Meteor.users.find {_id: @userId}

Meteor.publish 'allUserData', ->
  Meteor.users.find {}, {fields: {'_id': 1, 'username': 1, 'mail': 1, 'displayName': 1, 'department': 1, 'physicalDeliveryOfficeName': 1, 'status.online': 1, 'status.idle': 1}}

Meteor.publishComposite 'inventory', (filter, options) ->
  [itemSet, facets] = Inventory.findWithFacets filter, options
  itemSet = _.pluck itemSet.fetch(), '_id'
  {
    find: ->
      Counts.publish this, 'inventoryCount', Inventory.find(filter), { noReady: true }
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

# TODO: Add extra subs on checkouts for working reactivity or find a different pattern
Meteor.publishComposite 'checkouts', (checkoutFilter, inventoryFilter, options) ->
  if checkoutFilter
    ids = _.pluck Checkouts.find(checkoutFilter).fetch(), 'assetId'
  if ids then _.extend inventoryFilter, { _id: { $nin: ids } }
  _.extend inventoryFilter, { checkout: true }
  [itemSet, facets] = Inventory.findWithFacets inventoryFilter, options
  itemSet = _.pluck itemSet.fetch(), '_id'
  {
    find: ->
      Counts.publish this, 'checkoutCount', Inventory.find(inventoryFilter), { noReady: true }
      Inventory.find { _id: { $in: itemSet } }
    children: [
      {
        find: (item) ->
          ids = _.pluck item.attachments, 'fileId' # not reactive
          FileRegistry.find { _id: { $in: ids } }
      }
      {
        find: (item) ->
          if checkoutFilter
            timeFilter = {
              assetId: item._id
              $or: [
                checkoutFilter
                { $or: [
                  { 'schedule.timeReserved': { $gte: new Date() } }
                  { 'schedule.expectedReturn': { $gte: new Date() } }
                ] }
              ]
            }
          else
            timeFilter = { assetId: item._id, $or: [
              {'schedule.timeReserved': { $gte: new Date() } }
              { 'schedule.expectedReturn': { $gte: new Date() } }
            ] }
          Checkouts.find timeFilter
      }
      {
        find: -> facets
      }
    ]
  }

Meteor.publish 'item', (itemId) ->
  [ Inventory.find({ _id: itemId }), Changelog.find({ itemId: itemId }) ]
