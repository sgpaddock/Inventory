setup = ->
  context = {}
  context.ready = new ReactiveVar(false)
  context.templateData = @data
  @data.settings = @data.settings || {}
  collection = @data.collection || @data.settings.collection || @data
  # Set up collection - determine if Collection or String
  if collection instanceof Mongo.Collection
    context.collection = collection
  else if _.isString(collection)
    if window[collection]
      context.collection = window[collection]
    else
      console.error("Error: No collection found with name #{collection}")
  else
    console.error("Error: argument is not a valid collection")
    context.collection = new Mongo.Collection(null)
  if collection.simpleSchema()
    context.schema = collection.simpleSchema()

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
    }

  context.fields = fields

  context.sortKey = new ReactiveVar()
  context.sortOrder = new ReactiveVar()

  # User defined settings
  context.class = @data.class || @data.settings.class || 'autotable table table-condensed'
  context.addButton = @data.addButton || @data.settings.addButton || false
  context.actionColumn = @data.actionColumn || @data.settings.actionColumn || false
  context.pageLimit = @data.pageLimit || @data.settings.pageLimit || 20
  
  # Action button custom templates
  context.insertTpl = @data.insertTpl || @data.settings.insertTpl
  context.updateTpl = @data.updateTpl || @data.settings.updateTpl
  context.cloneTpl = @data.cloneTpl || @data.settings.cloneTpl
  context.deleteTpl = @data.deleteTpl || @data.settings.deleteTpl

  context.skip = new ReactiveVar(0)
  context.getFilters = @data.filters || @data.settings.filters || -> {}
  
  context.subscription = @data.subscription || @data.settings.subscription
  if context.subscription
    context.publicationId = Random.id()
    context.handle = Meteor.subscribe "autotable-#{context.subscription}",
      context.publicationId,
      context.getFilters(),
      [],
      { limit: context.pageLimit },
      onReady: -> context.ready.set(true)
  else context.ready.set(true)
  @context = context

Template.autotable.helpers
  context: ->
    if !Template.instance().context or !_.isEqual(@, Template.instance().context.templateData)
      setup.call Template.instance()
    Template.instance().context

  ready: -> @ready.get()

  records: ->
    sort = {}
    sortKey = @sortKey.get()
    sort[sortKey] = @sortOrder.get() || -1
    if @subscription
      @collection.find({}, { sort: sort })
    else
      @collection.find(@getFilters(), { limit: @pageLimit, skip: @skip.get(), sort: sort })
    
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
    if @collection.find(@getFilters()).count() is 0 then 0 else @skip.get() + 1
  lastVisibleItem: ->
    Math.min @skip.get() + @pageLimit, (AutoTable.counts.findOne(@publicationId)?.count || @collection.find(@getFilters()).count())
  lastDisabled: ->
    if @skip.get() <= 0 then "disabled"
  nextDisabled: ->
    if @skip.get() + @pageLimit + 1 > (AutoTable.counts.findOne(@publicationId)?.count || @collection.find(@getFilters()).count()) then "disabled"
  itemCount: ->
    AutoTable.counts.findOne(@publicationId)?.count || @collection.find(@getFilters()).count()

Template.autotable.rendered = ->
  @autorun ->
    context = @.templateInstance().context
    if context.subscription
      sort = {}
      sortKey = context.sortKey.get()
      limit = context.pageLimit
      skip = context.skip.get()
      sort[sortKey] = context.sortOrder.get() || -1
      if context.handle then context.handle.stop()
      context.ready.set(false)
      context.handle = Meteor.subscribe "autotable-#{context.subscription}",
        context.publicationId,
        context.getFilters(),
        [],
        { limit: limit, skip: skip, sort: sort },
        onReady: -> context.ready.set(true)

Template.autotable.events
  'click button[data-action=insert]': (e,tpl) ->
    context = Template.instance().context
    Blaze.renderWithData (Template[context.insertTpl] || context.insertTpl || Template.insertModal),
      { collection: Inventory },
      $('body').get(0)
    $('#insertModal').modal('show')

  'click button[data-action=cloneItem]': (e, tpl) ->
    context = Template.instance().context
    Blaze.renderWithData (Template[context.cloneTpl] || context.cloneTpl || Template.cloneModal),
      { doc: @, collection: Inventory },
      $('body').get(0)
    $('#cloneModal').modal('show')

  'click button[data-action=deleteItem]': (e, tpl) ->
    context = Template.instance().context
    Blaze.renderWithData (Template[context.deleteTpl] || context.deleteTpl || Template.deleteModal),
      { doc: @, collection: Inventory },
      $('body').get(0)

    $('#deleteModal').modal('show')

  'click button[data-action=editItem]': (e,tpl) ->
    context = Template.instance().context
    Blaze.renderWithData (Template[context.updateTpl] || context.updateTpl || Template.updateModal),
      { doc: @, collection: Inventory },
      $('body').get(0)

    $('#updateModal').modal('show')

  'click span[class=autotable-field-heading]': (e) ->
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
    if skip + pageLimit < (AutoTable.counts.findOne(context.publicationId)?.count || context.collection.find().count())
      Template.instance().context.skip.set(skip + pageLimit)

  'click button[data-action=lastPage]': (e, tpl) ->
    skip = Template.instance().context.skip.get() || 0
    pageLimit = Template.instance().context.pageLimit

    newSkip = Math.max skip - pageLimit, 0
    Template.instance().context.skip.set(newSkip)

