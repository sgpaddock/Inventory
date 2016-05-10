setup = ->
  context = {}
  context.ready = new ReactiveVar(false)
  context.templateData = @data
  @data.settings = @data.settings || {}
  context.schema = Inventory.simpleSchema()

  fields = @data.fields || @data.settings.fields || _.filter context.schema._firstLevelSchemaKeys, (k) ->
    context.schema._schema[k].autotable?.included
    
  fields = _.filter fields, (k) ->
    # Filter out array keys in case one was somehow left in
    if _.isString(k) then k.indexOf('.$') == -1
    else k.key.indexOf('.$') == -1

  fields = _.map fields, (f) ->
    if _.isString(f) then f = { key: f } # SimpleSchema does weird things with obj inputs
    if _.isString(f.tpl) then f.tpl = Template[f.tpl]
    {
      key: f.key
      label: f.label || context.schema?.label(f.key) || f.key
      tpl: f.tpl
      sortable: if _.isUndefined(f.sortable) then true else f.sortable
    }

  context.fields = fields

  # If a default field to sort on is provided, sort on it. If not, use whatever field was given first.
  context.sortKey = new ReactiveVar(@data.defaultSort || @data.settings.defaultSort || fields[0].key)
  context.sortOrder = new ReactiveVar(1)

  # User defined settings
  context.class = @data.class || @data.settings.class || 'autotable table table-condensed'
  context.pageLimit = @data.pageLimit || @data.settings.pageLimit || 20

  context.skip = new ReactiveVar(0)
  context.getFilters = @data.filters || @data.settings.filters || -> {}
  @context = context

Template.inventoryTable.helpers
  context: ->
    if !Template.instance().context or !_.isEqual(@, Template.instance().context.templateData)
      setup.call Template.instance()
    Template.instance().context

  ready: -> @ready.get()

  records: ->
    sort = {}
    sortKey = @sortKey.get()
    sort[sortKey] = @sortOrder.get() || -1
    Inventory.find(@getFilters(), { sort: sort })
    
  fieldCount: (f) ->
    (f or @).fields.length + @actionColumn

  isSortKey: ->
    parentData = Template.parentData(1)
    @key is parentData.sortKey.get()

  isAscending: ->
    parentData = Template.parentData(1)
    parentData.sortOrder.get() is 1

  getField: (doc) -> doc[@key]

  fieldCellContext: (doc) ->
    {
      fieldName: @key
      value: doc[@key]
      documentId: doc._id
    }

  firstVisibleItem: ->
    if Inventory.find(@getFilters()).count() is 0 then 0 else @skip.get() + 1
  lastVisibleItem: ->
    Math.min @skip.get() + @pageLimit, (Counts.get('inventoryCount') || Inventory.find(@getFilters()).count())
  lastDisabled: ->
    if @skip.get() <= 0 then "disabled"
  nextDisabled: ->
    if @skip.get() + @pageLimit + 1 > (Counts.get('inventoryCount') || Inventory.find(@getFilters()).count()) then "disabled"
  itemCount: ->
    Counts.get('inventoryCount') || Inventory.find(@getFilters()).count()

Template.inventoryTable.events
  'click span[class=inventory-table-heading]': (e) ->
    sortKey = Template.instance().context.sortKey.get()
    sortOrder = Template.instance().context.sortOrder.get()
    if sortKey is $(e.target).data('sort-key')
      Template.instance().context.sortOrder.set (-1 * sortOrder)
    else
      Template.instance().context.sortOrder.set 1
    Template.instance().context.sortKey.set $(e.target).data('sort-key')

  'click button[data-action=nextPage]': (e, tpl) ->
    context = Template.instance().context
    skip = context.skip.get()
    pageLimit = context.pageLimit
    if skip + pageLimit < (Counts.get('inventoryCount') || Inventory.find().count())
      Template.instance().context.skip.set(skip + pageLimit)

  'click button[data-action=lastPage]': (e, tpl) ->
    skip = Template.instance().context.skip.get() || 0
    pageLimit = Template.instance().context.pageLimit

    newSkip = Math.max skip - pageLimit, 0
    Template.instance().context.skip.set(newSkip)


Template.inventoryTable.rendered = ->
  @autorun ->
    context = @.templateInstance().context
    sort = {}
    sortKey = context.sortKey.get()
    limit = context.pageLimit
    skip = context.skip.get()
    sort[sortKey] = context.sortOrder.get() || -1

    Meteor.subscribe 'inventory',
      context.getFilters(),
      { limit: limit, skip: skip, sort: sort },
      onReady: ->
        context.ready.set(true)
      onStop: ->
        context.ready.set(false)

    Meteor.subscribe 'newInventory', context.getFilters(), new Date()
