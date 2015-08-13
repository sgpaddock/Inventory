excludedKeys = [ 'enteredByUserId', 'imageId', 'barcode']

Template.inventory.helpers
  context: ->
    # This is totally unnecessary at the moment
    context = _.extend {}, @

    schema = Inventory.simpleSchema()._schema
    fieldKeys = _.filter _.difference(_.keys(schema), excludedKeys), (k) -> k.indexOf('.$') == -1
    context.fields = _.map fieldKeys, (k) ->
      fieldName: k
    return context

  assets: -> Inventory.find()

  fieldCellContext: (fn, doc) ->
    { fieldName: fn, value: doc[fn], tpl: customTemplates[fn] }

  renderCell: ->
    Template[@tpl] or Template.atDefaultField

Template.inventory.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')


# This is the thing where the autotable package being fleshed out would be very helpful, to have something like
# AutoTable.configureTemplates
#   fieldName: 'owner'
#   template: 'customOwnerField'

customTemplates = {
  owner: 'ownerField'
  attachments: 'attachmentField'
}
