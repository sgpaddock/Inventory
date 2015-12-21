Template.checkoutAvailableField.helpers
  checkout: ->
    Checkouts.findOne { assetId: @_id }
