excludedKeys = [ 'attachments', 'enteredByUserId', 'imageId', 'barcode', 'attachments.$', 'attachments.$.purpose', 'attachments.$.fileId']

Template.inventory.helpers
  collection: -> Inventory
  fields: -> _.difference _.keys(Inventory.simpleSchema()._schema), excludedKeys
  assets: -> Inventory.find()

  fieldCellContext: (fn, doc) ->
    { fieldName: fn, value: doc[fn] }

Template.inventory.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')
