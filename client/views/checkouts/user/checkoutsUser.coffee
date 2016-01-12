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

Template.checkoutsUser.helpers
  settings: ->
    {
      fields: ['name', 'modelNo', 'deviceType', 'manufacturer',
        { key: 'available', label: 'Available?', tpl: Template.checkoutAvailableField, sortable: false }
      ]
      inventoryFilters: inventoryFilters
      checkoutFilters: checkoutFilters
    }

Template.checkoutsUser.events
  'click tr': (e, tpl) ->
    Blaze.renderWithData Template.checkoutModalUser, { docId: $(e.currentTarget).data('doc') }, $('body').get(0)
    $('#checkoutModalUser').modal('show')
