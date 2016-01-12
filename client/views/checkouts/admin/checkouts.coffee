checkoutFilters = ->
  {
    $or: [
      { $and: [
        { 'schedule.timeReserved': { $gte: new Date Iron.query.get('startDate') } }
        { 'schedule.timeReserved': { $lte: new Date Iron.query.get('endDate') } }
      ] },
      { $and: [
        { 'schedule.expectedReturn': { $gte: new Date Iron.query.get('startDate') } }
        { 'schedule.expectedReturn': { $lt: new Date Iron.query.get('endDate') } }
      ] }
    ]
  }

inventoryFilters = ->
  filters = {
    deviceType: Iron.query.get 'deviceType'
  }

  for k,v of filters
    if _.isUndefined(v) then delete filters[k]
  return filters

Template.checkoutsAdmin.helpers
  settings: ->
    {
      fields: ['name', 'modelNo', 'deviceType', 'manufacturer',
        { key: 'status', label: 'Status', tpl: Template.checkoutStatusField, sortable: false }
      ]
      inventoryFilters: inventoryFilters
      checkoutFilters: checkoutFilters
    }

Template.checkoutsAdmin.events
  'click tr': (e, tpl) ->
    Blaze.renderWithData Template.checkoutModalAdmin, { docId: $(e.currentTarget).data('doc') }, $('body').get(0)
    $('#checkoutModalAdmin').modal('show')
