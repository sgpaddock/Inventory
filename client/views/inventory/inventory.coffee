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

  assets: ->
    sortKey = Session.get('sortKey') || 'name'
    sort = {}
    sort[sortKey] = Session.get('sortOrder') || -1
    Inventory.find {}, {sort: sort}

  fieldCellContext: (fn, doc) ->
    { fieldName: fn, value: doc[fn], tpl: customTemplates[fn] }

  renderCell: ->
    Template[@tpl] or Template.atDefaultField

  isSortkey: ->
    @fieldName is Session.get('sortKey')

  isAscending: ->
    Session.get('sortOrder') is 1

Template.inventory.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')

  'click span[class=field-table-heading]': (e, tpl) ->
    if Session.get('sortKey') is $(e.target).data('sort-key')
      Session.set 'sortOrder', (-1 * Session.get('sortOrder'))
    else
      Session.set 'sortOrder', 1
    Session.set 'sortKey', $(e.target).data('sort-key')


# This is the thing where the autotable package being fleshed out would be very helpful, to have something like
# AutoTable.configureTemplates
#   fieldName: 'owner'
#   template: 'customOwnerField'

customTemplates = {
  owner: 'ownerField'
  attachments: 'attachmentField'
}

