Template.checkoutStatusField.helpers
  status: ->
    checkout = Checkouts.findOne { assetId: @documentId, 'schedule.timeReserved': { $lte: new Date() }, 'schedule.expectedReturn': { $gte: new Date() } , 'approval.approved': true }
    if checkout
      {
        message: if false then "Assigned to: #{Meteor.users.findOne(checkout.assignedTo).username}" else "Unavailable"
        class: "unavailable"
      }
    else
      {
        message: "Available"
        class: "available"
      }

