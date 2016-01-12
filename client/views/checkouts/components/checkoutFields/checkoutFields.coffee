Template.checkoutStatusField.helpers
  status: ->
    checkout = Checkouts.findOne { assetId: @documentId, 'schedule.timeReserved': { $lte: new Date() }, 'schedule.expectedReturn': { $gte: new Date() } }
    if checkout
      {
        message: "Assigned to: #{Meteor.users.findOne(checkout.assignedTo).username}"
        class: "unavailable"
      }
    else
      {
        message: "Available"
        class: "available"
      }
