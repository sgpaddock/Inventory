Template.viewReservationsModalUser.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  currentlyCheckedOut: ->
    Checkouts.findOne({
      assetId: @assetId
      'schedule.timeCheckedOut': { $exists: true }
      'schedule.timeReturned': { $exists: false }
    })?

Template.viewReservationsModalUser.events
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
    Blaze.renderWithData Template.checkInModal, { docId: @assetId }, $('body').get(0)
    $('#checkInModal').modal('show')

  'click button[data-action=checkOut]': (e, tpl) ->
    Blaze.renderWithData Template.confirmCheckoutModal, this, $('body').get(0)
    $('#confirmCheckoutModal').modal('show')

  'click button[data-action=approve]': (e, tpl) ->
    Checkouts.update @_id, { $set: { 'approval.approved': true, 'approval.approverId': Meteor.userId() } }

  'click button[data-action=reject]': (e, tpl) ->
    Checkouts.update @_id, { $set: { 'approval.approved': false, 'approval.approverId': Meteor.userId() } }

Template.viewReservationsModalUser.onCreated ->
  @error = new ReactiveVar
  @checkSuccess = new ReactiveVar
