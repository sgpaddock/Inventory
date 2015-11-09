AutoTable = AutoTable || {}
# AutoTable.publish is called on the server. A collection is passed to it, as well as a default
# Mongo selector (if limiting the result set is needed on the server) 
AutoTable.publish = (name, collectionOrFunction, selectorOrFunction, noRemoval) ->
  Meteor.publish "autotable-#{name}", (publicationId, filters, fields, options) ->
    ###
    check publicationId, String
    check filters, [ Match.OneOf(String, Object) ]
    check fields, [[String]]
    check options, { skip: Match.Integer, limit: Match.Integer, sort: Object }
    ###
    self = @

    if _.isFunction(collectionOrFunction)
      collection = collectionOrFunction.call @
    else
      collection = collectionOrFunction

    if _.isFunction(selectorOrFunction)
      selector = selectorOrFunction.call @
    else
      selector = selectorOrFunction
    
    unless collection instanceof Mongo.Collection
      console.log 'Collection is not a valid collection'
    [cursor, facetCursor] = collection.findWithFacets(selector, options)
    count = cursor.count()
    
    getRow = (row, idx) ->
      _.extend {
        'autotable-id': publicationId
        'autotable-sort': idx
      }, row

    getRows = ->
      _.map cursor.fetch(), getRow

    rows = {}
    _.each getRows(), (row) ->
      rows[row._id] = row


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

    self.added "autotable-counts-#{name}", publicationId, { count: count }
    _.each rows, (row) ->
      self.added collection._name, row._id, row

    initializing = true
    handle = cursor.observeChanges
      added: (id, fields) ->
        unless initializing
          self.changed "autotable-counts", publicationId, { count: cursor.count() }
          updateRows()
        
      changed: (id, fields) ->
        updateRows()

      removed: (id, fields) ->
        unless noRemoval?
          self.removed collection._name, id
          delete rows[id]
          updateRows()

        self.changed "autotable-counts", publicationId, { count: cursor.count() }

    initializing = false

    # TODO: Clean this up   
    facetHandle = facetCursor.observeChanges
      added: (id, fields) ->
        unless initializing
          self.added 'facets', id, fields
      changed: (id, fields) ->
        self.changed 'facets', id, fields
      removed: (id, fields) ->
        self.removed 'facets', id


    
    self.ready()

    self.onStop ->
      handle.stop()
      facetHandle.stop()
