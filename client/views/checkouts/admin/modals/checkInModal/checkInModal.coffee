Template.checkInModal.helpers
  item: -> Inventory.findOne(@assetId)
  error: -> Template.instance().error.get()
  success: -> Template.instance().success.get()

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

Template.checkInModal.onCreated ->
  @error = new ReactiveVar()
  @success = new ReactiveVar(false)
