Template.checkoutFilters.events
  'changeDate .datepicker': (e, tpl) ->
    Iron.query.set $(e.target).data('filter'), moment(e.date).format('YYYY-MM-DD')
    tpl.$('#startDatepicker').datepicker('setEndDate', new Date(Iron.query.get 'endDate'))
    tpl.$('#endDatepicker').datepicker('setStartDate', new Date(Iron.query.get 'startDate'))

Template.checkoutFilters.helpers
  startDate: -> Iron.query.get 'startDate' || '1960-01-01'
  endDate: -> Iron.query.get 'endDate' || '2100-12-31'
  facetKeys: -> [
    { key: 'deviceType', label: 'Device Type' }
  ]
  selection: -> Iron.query.get(@key) || "Any"
  value: ->
    key = @key
    active = Iron.query.get(key)?.split(',') || []
    _.map _.sortBy(Facets.findOne()?.facets[key], (f) -> -f.count), (l) ->
      _.extend l,
        key: key
        checked: if l.name in active then 'checked'

Template.checkoutFilters.rendered = ->
  this.$('#startDatepicker').datepicker({
    endDate: new Date(Iron.query.get('endDate'))
    clearBtn: true
  })
  
  this.$('#endDatepicker').datepicker({
    startDate: new Date(Iron.query.get('startDate'))
    clearBtn: true
  })
