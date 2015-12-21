Template.checkoutModal.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.findOne { assetId: @_id }
  admin: -> true

Template.checkoutModal.rendered = ->
  @$('.datepicker').datepicker({
    orientation: "top" # up is down
  })

Template.checkoutModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
