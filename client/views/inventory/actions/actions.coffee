Template.inventoryActions.helpers
  admin: -> Roles.userIsInRole Meteor.userId(), 'admin'
  exportUrl: -> Router.current().originalUrl.replace('inventory', 'export')

Template.inventoryActions.events
  'click button[data-action=addNewAsset]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')

  'click button[data-action=bulkRecordPickup]': (e, tpl) ->
    # Using Session to communicate data here
    Blaze.render Template.bulkRecordPickupModal, $('body').get(0)
    $('#bulkRecordPickupModal').modal('show')
