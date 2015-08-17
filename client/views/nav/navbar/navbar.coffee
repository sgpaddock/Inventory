Template.navbar.helpers
  facetKeys: ->
    if Facets.findOne()
      _.keys(Facets.findOne().facets)
  value: ->
    key = @.valueOf()
    if Iron.query.get(key)
      active = Iron.query.get(key).split(',')
    else
      active = []
    _.map _.sortBy(Facets.findOne()?.facets[@], (f) -> -f.count), (l) ->
      _.extend l,
        key: key
        checked: if l.name in active then 'checked'



Template.navbar.events
  'click a[id=logout]': ->
    Meteor.logout()

  'click .yamm .dropdown-menu': (e, tpl) ->
    e.stopPropagation()



Template.facetCheckbox.helpers
  checked: (k) ->
    active = Iron.query.get(k)?.split(',') || []
    if @name in active then 'checked'

Template.facetCheckbox.events
  'change input:checkbox': (e, tpl) ->
    console.log this
    cur = Iron.query.get(@key)?.split(',') || []
    if $(e.target).is(':checked')
      cur.push @name
    else
      cur = _.without cur, @name

    Iron.query.set @key, _.uniq(cur).join()
