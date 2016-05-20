Template.checkInModal.helpers
  item: -> Inventory.findOne(@docId)
  checkout: ->
    Checkouts.findOne {
      assetId: @docId
      'schedule.timeCheckedOut': { $lte: new Date() }
      'schedule.timeReturned': { $exists: false }
    }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName


Template.checkInModal.events
  'show.bs.modal': (e, tpl) ->
    zIndex = 1040 + ( 10 * $('.modal:visible').length)
    $(e.target).css('z-index', zIndex)
    setTimeout ->
      $('.modal-backdrop').not('.modal-stack').css('z-index',  zIndex-1).addClass('modal-stack')
    , 10

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
    if $('.modal:visible').length
      $(document.body).addClass('modal-open')

  'click button[data-action=checkIn]': (e, tpl) ->
    Checkouts.update @_id, { $set:
      'schedule.timeReturned': new Date()
      'schedule.checkedInBy': Meteor.userId()
    }
    $('#checkInModal').modal('hide')
