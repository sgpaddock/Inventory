Template.checkoutFilters.events
  'changeDate .datepicker': (e, tpl) ->
    Iron.query.set $(e.target).data('filter'), moment(e.date).format('YYYY-MM-DD')

Template.checkoutFilters.helpers
  startDate: -> Iron.query.get 'startDate' || '1960-01-01'
  endDate: -> Iron.query.get 'endDate' || '2100-12-31'

Template.checkoutFilters.rendered = ->
  this.$('.datepicker').datepicker()
