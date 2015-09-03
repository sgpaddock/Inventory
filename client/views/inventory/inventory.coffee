Template.inventory.helpers
  fields: -> [ 'name', 'description', 'propertyTag', 'deviceType', 'serialNo', 'manufacturer', 'modelNo', 'department', 'owner', 'building', 'officeNo', 'attachments' ]
  ready: -> Session.get 'ready'

Template.inventory2.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')

Tracker.autorun ->
  Meteor.subscribe 'inventorySet', Session.get('itemSet')
  filter = Filter.getFilterFromQuery Iron.query.get()
  Inventory.find(filter).observe
    added: (item) ->
      Session.set 'itemSet', _.uniq(Session.get('itemSet')?.concat(item._id)) || [ item._id ]


