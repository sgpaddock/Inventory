Template.facetDropdown.helpers
  facetKeys: ->
    ###
    if Facets.findOne()
      _.keys(Facets.findOne().facets)
    ###
    
    # If we don't hard code these in, they'll flicker whenever we filter.
    [
      { key: 'department', label: 'Department' }
      { key: 'owner', label: 'Owner' }
      { key: 'location', label: 'Location' }
      { key: 'model', label: 'Model' }
    ]
  value: ->
    key = @key
    active = Iron.query.get(key)?.split(',') || []
    _.map _.sortBy(Facets.findOne()?.facets[key], (f) -> -f.count), (l) ->
      _.extend l,
        key: key
        checked: if l.name in active then 'checked'

  selection: -> Iron.query.get(@key) || "Any"

Template.facetCheckbox.events
  'change input:checkbox': (e, tpl) ->
    cur = Iron.query.get(@key)?.split(',') || []
    if $(e.target).is(':checked')
      cur.push @name
    else
      cur = _.without cur, @name

    Iron.query.set @key, _.uniq(cur).join()
