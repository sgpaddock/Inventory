getFilters = ->
  filters = {
    department: Iron.query.get 'department'
    owner: Iron.query.get 'owner'
    building: Iron.query.get 'building'
  }

  for k,v of filters
    if _.isUndefined(v)
      delete filters[k]

  return filters

Template.checkouts.helpers
  settings: ->
    {
      subscription: "checkouts"
      fields: ['name', 'modelNo', 'deviceType', 'manufacturer',
        { key: 'available', label: 'Available?', tpl: Template.checkoutAvailableField }
      ]
      filters: getFilters
    }

Template.checkouts.events
  'click tr': (e, tpl) ->
    Blaze.renderWithData Template.checkoutModal, { docId: $(e.currentTarget).data('doc') }, $('body').get(0)
    $('#checkoutModal').modal('show')
