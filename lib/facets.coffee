@Filter =
  getFilterFromQuery: (query) ->
    unless _.keys(query).length is 0
      filter = {}
      filter.$and = []

      for k,v of query
        obj = {}
        obj[k] = { $in: v.split(',') }
        filter.$and.push obj

      return filter

if Meteor.isServer
  Facets.configure Inventory,
    department: String
    owner: String
    building: String
