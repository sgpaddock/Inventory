Template.checkoutStatusField.helpers
  status: ->
    if Checkouts.findOne { assetId: @documentId, 'schedule.timeCheckedOut': { $exists: true }, 'schedule.timeReturned': { $exists: false } }
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


Template.checkoutActionsAdminField.events
  'click button[data-toggle=modal]': (e, tpl) ->
    modal = tpl.$(e.currentTarget).data('modal')
    Blaze.renderWithData Template[modal], { docId: tpl.data.documentId } , $('body').get(0)
    $("##{modal}").modal('show')

Template.checkoutActionsAdminField.helpers
  checkedOut: ->
    Checkouts.findOne({
      assetId: @documentId
      'schedule.timeCheckedOut': { $exists: true }
      'schedule.timeReturned': { $exists: false }
    })?

Template.checkoutActionsUserField.events
  'click button[data-toggle=modal]': (e, tpl) ->
    modal = tpl.$(e.currentTarget).data('modal')
    Blaze.renderWithData Template[modal], { docId: tpl.data.documentId } , $('body').get(0)
    $("##{modal}").modal('show')
