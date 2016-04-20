Template.checkoutModalUser.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  checkoutShouldBeDisplayed: ->
    @approval?.approved is true or @assignedTo is Meteor.userId()

Template.checkoutModalUser.rendered = ->
  tpl = @
  @.$('.datepicker').datepicker({
    todayHighlight: true
    orientation: "top"
    beforeShowDay: (date) ->
      if Checkouts.findOne({ assetId: tpl.data.docId, 'schedule.timeReserved': { $lte: date }, 'schedule.expectedReturn': { $gte: date }})
        return { enabled: false, classes: "datepicker-date-reserved", tooltip: "Reserved" }
  })

Template.checkoutModalUser.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[data-action=submit]': (e, tpl) ->
    # TODO: Permissions. Maybe move everything into methods.
    tpl.error.set(null)
    today = new Date()
    if new Date(tpl.$('input[name=timeReserved]').val()) < today
      tpl.error.set "Item reservation time must be after today."
    if new Date(tpl.$('input[name=timeReserved]').val()) > new Date(tpl.$('input[name=timeReserved]').val())
      tpl.error.set "Expected return must be after desired reservation date."
    if not tpl.$('input[name=timeReserved]').val()
      tpl.error.set "Item reservation time is required."
    if not tpl.$('input[name=expectedReturn]').val()
      tpl.error.set "Expected return time is required."

    if not tpl.error.get()
      timeReserved = new Date(tpl.$('input[name=timeReserved]').val())
      expectedReturn = new Date(tpl.$('input[name=expectedReturn]').val())
      checkout = Checkouts.findOne {
        assetId: tpl.data.docId
        'schedule.timeReserved': { $lte: expectedReturn }
        'schedule.expectedReturn': { $gte: timeReserved }
      }
      if checkout
        tpl.error.set('This reservation would overlap with another. Please consider a different item or reservation window.')
      else
        Checkouts.insert
          assetId: tpl.data.docId
          assignedTo: Meteor.userId()
          schedule:
            timeReserved: new Date(tpl.$('input[name=timeReserved]').val())
            expectedReturn: new Date(tpl.$('input[name=expectedReturn]').val())

Template.checkoutModalUser.onCreated ->
  this.error = new ReactiveVar()
