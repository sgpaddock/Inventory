Template.checkoutStatusField.helpers
  status: ->
    if Checkouts.findOne { assetId: @documentId, 'schedule.timeCheckedOut': { $lte: new Date() }, 'schedule.timeReturned': { $exists: false } }
      message = "Checked Out"
      css = "unavailable"
    else if Checkouts.findOne { assetId: @documentId, 'schedule.timeReserved': { $lte: new Date() }, 'schedule.expectedReturn': { $gte: new Date() } , 'approval.approved': true }
      message = "Reserved"
      css = "unavailable"
    else
      message = "Available"
      css = "available"
    return {
      message: message
      class: css
    }
