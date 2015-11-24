AutoTable = AutoTable || {}
# AutoTable.publish is called on the server. A collection is passed to it, as well as a default
# Mongo selector (if limiting the result set is needed on the server) 
AutoTable.publish = (name, collectionOrFunction, selectorOrFunction, noRemoval) ->
  Meteor.publish "autotable-#{name}", (publicationId, filters, fields, options) ->
    check publicationId, String
    check filters, Match.OneOf(Object, null)
    check fields, [[String]]
    #check options, { skip: Match.OneOf(Match.Integer, null), limit: Match.OneOf(Match.Integer, null), sort: Object }
    self = @

    if _.isFunction(collectionOrFunction)
      collection = collectionOrFunction.call @
    else
      collection = collectionOrFunction

    if _.isFunction(selectorOrFunction)
      selector = selectorOrFunction.call @
    else
      selector = selectorOrFunction || {}
    if filters
      _.extend selector, filters

    unless collection instanceof Mongo.Collection
      console.log 'Collection is not a valid collection'
    [cursor, facetCursor] = collection.findWithFacets(selector, options)
    count = cursor.count()
    if noRemoval
      ids = _.pluck cursor.fetch(), '_id'
    else
      ids = []
    newCursor = collection.find { $or: [ { _id: { $in: ids } }, selector ] }, options
    
    
    getRow = (row, idx) ->
      _.extend {
        'autotable-id': publicationId
        'autotable-sort': idx
      }, row

    getRows = ->
      _.map newCursor.fetch(), getRow

    rows = {}
    _.each getRows(), (row) ->
      rows[row._id] = row

    if noRemoval
      deletedRows = []

    updateRows = ->
      newRows = getRows()
      _.each newRows, (row, idx) ->
        oldRow = rows[row._id]
        if oldRow
          unless _.isEqual(oldRow, row)
            self.changed collection._name, row._id, row
            rows[row._id] = row
        else
          self.added collection._name, row._id, row
          rows[row._id] = row
     
    self.added "autotable-counts", publicationId, { count: count }
    _.each rows, (row) ->
      self.added collection._name, row._id, row

    initializing = true
    handle = newCursor.observeChanges
      added: (id, fields) ->
        unless initializing
          self.changed "autotable-counts", publicationId, { count: cursor.count() }
          updateRows()
        
      changed: (id, fields) ->
        updateRows()

      removed: (id, fields) ->
        updateRows()
        self.removed collection._name, id
        unless noRemoval
          delete rows[id]

        self.changed "autotable-counts", publicationId, { count: cursor.count() }

    initializing = false

    facetInitializing = true
    facetHandle = facetCursor.observeChanges
      added: (id, fields) ->
        unless initializing
          self.added 'facets', id, fields
      changed: (id, fields) ->
        self.changed 'facets', id, fields
      removed: (id, fields) ->
        self.removed 'facets', id

    facetInitializing = false

    self.ready()

    self.onStop ->
      handle.stop()
      facetHandle.stop()
