Template.reserveModalAdmin.helpers
  item: -> Inventory.findOne { _id: @docId }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  checkSuccess: -> Template.instance().checkSuccess.get() is true # Exact comparison so we dont accidentally give fail result
  checkFail: -> Template.instance().checkSuccess.get() is false

Template.reserveModalAdmin.rendered = ->
  tpl = @
  @.$('.datepicker').datepicker({
    todayHighlight: true
    orientation: "up" # up is down
    daysOfWeekDisabled: ['0','6']
    beforeShowDay: (date) ->
      if Checkouts.findOne({ assetId: tpl.data.docId, 'schedule.timeReserved': { $lte: date }, 'schedule.expectedReturn': { $gte: date, }, 'schedule.timeReturned': { $exists: false }, 'approval.approved': { $ne: false }})
        return { enabled: false, classes: "datepicker-date-reserved", tooltip: "Reserved" }
  })

Template.reserveModalAdmin.events
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

  'click button[data-action=checkUsername], keyup input[name=onBehalfOf]': (e, tpl) ->
    if e.keyCode is 13 or !e.keyCode
      checkUsername tpl

   'autocompleteselect input[name=onBehalfOf]': (e, tpl) ->
     tpl.checkSuccess.set true

  'click button[data-action=submit]': (e, tpl) ->
    # TODO: Permissions. Maybe move everything into methods.
    tpl.error.set null
    yesterday = moment().subtract(1, 'days').hours(23).minutes(59).seconds(59).toDate()
    if new Date(tpl.$('input[name=timeReserved]').val()) < yesterday
      tpl.error.set "Item reservation time cannot be in the past."
    if new Date(tpl.$('input[name=timeReserved]').val()) > new Date(tpl.$('input[name=timeReserved]').val())
      tpl.error.set "Expected return must be after desired reservation date."
    if not tpl.$('input[name=timeReserved]').val()
      tpl.error.set "Item reservation time is required."
    if not tpl.$('input[name=expectedReturn]').val()
      tpl.error.set "Expected return time is required."
    
    if not tpl.error.get()
      if tpl.$('input[name=onBehalfOf]').val()
        Meteor.call 'checkUsername', tpl.$('input[name=onBehalfOf]').val(), (err, res) ->
          if res
            insertCheckout e, tpl, res
            tpl.$('#reserveModalAdmin').modal('hide')
          else
            tpl.checkSuccess.set false
            tpl.error.set "User not found."
      else
        insertCheckout e, tpl, Meteor.userId()
        tpl.$('#reserveModalAdmin').modal('hide')

  'click .checkout-action-btn': (e, tpl) ->
    e.stopPropagation()

  'click button[data-action=checkOut]': (e, tpl) ->
    Blaze.renderWithData Template.confirmCheckoutModal, this, $('body').get(0)
    $('#confirmCheckoutModal').modal('show')

  'click button[data-action=checkIn]': (e, tpl) ->
    Blaze.renderWithData Template.checkInModal, this, $('body').get(0)
    $('#checkInModal').modal('show')

Template.reserveModalAdmin.onCreated ->
  @error = new ReactiveVar
  @checkSuccess = new ReactiveVar

insertCheckout = (e, tpl, userId) ->
  timeReserved = new Date(tpl.$('input[name=timeReserved]').val())
  expectedReturn = new Date(tpl.$('input[name=expectedReturn]').val())
  if tpl.$('textarea[name=notes]').val()
    notes = [ {
      message: tpl.$('textarea[name=notes]').val()
      authorId: Meteor.userId()
      timestamp: new Date()
    } ]
  checkout = Checkouts.findOne {
    assetId: tpl.data.docId
    'approval.approved': { $ne: false }
    'schedule.timeReserved': { $lte: expectedReturn }
    'schedule.expectedReturn': { $gte: timeReserved }
    'schedule.timeReturned': { $exists: false }
  }
  if checkout
    tpl.error.set('This reservation would overlap with another. Please consider a different item or reservation window.')
  else
    Checkouts.insert {
      assetId: tpl.data.docId
      assignedTo: userId
      notes: notes
      schedule:
        timeReserved: timeReserved
        expectedReturn: expectedReturn
      approval:
        approved: true
        approverId: Meteor.userId()
    }, (err, res) ->
      if res
        tpl.checkSuccess.set null
        tpl.$('input[name=timeReserved]').val("")
        tpl.$('input[name=expectedReturn]').val("")
        tpl.$('textarea[name=notes]').val("")
        tpl.$('input[name=onBehalfOf]').val("")


checkUsername = (tpl, winCb, failCb) ->
  val = tpl.$('input[name=onBehalfOf]').val()
  unless val.length < 1
    Meteor.call 'checkUsername', val, (err, res) ->
      if res
        tpl.checkSuccess.set true
        if winCb then winCb()
      else
        tpl.checkSuccess.set false
        if failCb then failCb()

