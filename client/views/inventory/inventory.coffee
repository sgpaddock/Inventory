excludedKeys = [ 'enteredByUserId', 'imageId', 'barcode', 'enteredAtTimestamp', 'category', 'quantity', 'quantityUnit' ]

Template.inventory.helpers
  context: ->
    # This is totally unnecessary at the moment
    context = _.extend {}, @

    ss = Inventory.simpleSchema()
    fieldKeys = _.filter _.difference(ss._schemaKeys, excludedKeys), (k) -> k.indexOf('.$') == -1
    context.fields = _.map fieldKeys, (k) ->
      fieldName: k
      fieldLabel: ss.label(k)
    return context

  assets: ->
    sort = {}
    sortKey = Session.get('sortKey') || 'name'
    sort[sortKey] = Session.get('sortOrder') || -1
    Inventory.find {}, {sort: sort}

  fieldCellContext: (fn, doc) ->
    { fieldName: fn, value: doc[fn], tpl: customTemplates[fn] }

  renderCell: ->
    Template[@tpl] || Template.atDefaultField

  oneItem: ->
    # Check if there's an item in the local db. Maybe could be a better name for this.
    Inventory.findOne()
  columnCount: ->
    _.difference(_.keys(Inventory.simpleSchema()._schema), excludedKeys).length
  isSortkey: ->
    @fieldName is Session.get('sortKey')

  isAscending: ->
    Session.get('sortOrder') is 1

  filter: ->
    _.keys(Iron.query.get()).length > 0

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
 
  'click a[data-action=clearFilter]': (e, tpl) ->
    e.stopPropagation()
    _.each _.keys(Iron.query.get()), (k) ->
      Iron.query.set k

# This is the thing where the autotable package being fleshed out would be very helpful, to have something like
# AutoTable.configureTemplates
#   fieldName: 'owner'
#   template: 'customOwnerField'

customTemplates = {
  owner: 'ownerField'
  attachments: 'attachmentField'
  department: 'departmentField'
  building: 'buildingField'
  officeNo: 'officeNoField'
}

Tracker.autorun ->
  Meteor.subscribe 'inventorySet', Session.get('itemSet')
  filter = Filter.getFilterFromQuery Iron.query.get()
  Inventory.find(filter).observe
    added: (item) ->
      Session.set 'itemSet', _.uniq(Session.get('itemSet')?.concat(item._id)) || [ item._id ]
