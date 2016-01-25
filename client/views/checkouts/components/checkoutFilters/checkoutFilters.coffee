Template.checkoutFilters.events
  'changeDate .datepicker': (e, tpl) ->
    if e.date
      Iron.query.set $(e.target).data('filter'), moment(e.date).format('YYYY-MM-DD')
    else
      # Clear button
      Iron.query.set $(e.target).data('filter'), null
    
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
    clearBtn: true
    todayHighlight: true
  })
  
  this.$('#endDatepicker').datepicker({
    todayHighlight: true
    clearBtn: true
  })
