Template.checkoutModal.helpers
  item: -> Inventory.findOne { _id: @docId }
