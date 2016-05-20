checkoutFilters = ->
  startDate = null
  endDate = null
  if Iron.query.get('startDate')
    startDate = new Date Iron.query.get('startDate')
  if Iron.query.get('endDate')
    endDate = new Date Iron.query.get('endDate')
  {
    $or: [
      { $and: [
        { 'schedule.timeReserved': { $gte: startDate } }
        { 'schedule.timeReserved': { $lte: endDate } }
      ] },
      { $and: [
        { 'schedule.expectedReturn': { $gte: startDate } }
        { 'schedule.expectedReturn': { $lt: endDate } }
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
        { key: 'actions', label: 'Actions', tpl: Template.checkoutActionsAdminField, sortable: false }
      ]
      inventoryFilters: inventoryFilters
      checkoutFilters: checkoutFilters
    }

