Template.checkouts.helpers
  settings: ->
    {
      collection: Inventory
      subscription: 'checkouts'
      fields: ['name', 'model', 'deviceType', 'manufacturer']
    }
