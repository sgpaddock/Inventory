Template.viewReservationsModalAdmin.helpers
  isAdmin: -> Roles.userIsInRole Meteor.userId(), 'admin'
  isViewingFullHistory: -> Template.instance().viewFullHistory.get()
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }, { sort: { 'schedule.timeReserved': 1 } }
  overdue: ->
    today = moment().hours(0).minutes(0).seconds(0).toDate()
    @schedule?.expectedReturn < today and (not @schedule.timeReturned?) and @schedule.timeCheckedOut?
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  rejectingThisCheckout: -> Template.instance().rejecting.get() is @_id
  currentlyCheckedOut: ->
    Checkouts.findOne({
      assetId: @assetId
      'schedule.timeCheckedOut': { $exists: true }
      'schedule.timeReturned': { $exists: false }
    })?

Template.viewReservationsModalAdmin.events
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
    tpl.rejecting.set @_id

  'click button[data-action=cancelRes]': (e, tpl) ->
    Blaze.renderWithData Template.cancelCheckoutModal, { assetId: @assetId, checkoutId: @_id }, $('body').get(0)
    $('#cancelCheckoutModal').modal('show')

  'click button[data-action=rejectConfirm]': (e, tpl) ->
    Checkouts.update @_id, { $set: {
      approval:
        approved: false
        approverId: Meteor.userId()
        reason: tpl.$('input[name=reason]').val()
    } }
    tpl.rejecting.set null

  'click button[data-action=showFullHistory]': (e, tpl) ->
    tpl.subscribe 'checkoutHistory', tpl.data.docId
    tpl.viewFullHistory.set true

Template.viewReservationsModalAdmin.onCreated ->
  @viewFullHistory = new ReactiveVar false
  @error = new ReactiveVar
  @checkSuccess = new ReactiveVar
  @rejecting = new ReactiveVar null
