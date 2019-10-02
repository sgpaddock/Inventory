Template.reserveModalUser.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  warning: -> Template.instance().warning.get()
  success: -> Template.instance().success.get()

Template.reserveModalUser.rendered = ->
  tpl = @
  @.$('.datepicker').datepicker
    todayHighlight: true
    orientation: "up"
    daysOfWeekDisabled: ['0','6']
    beforeShowDay: (date) ->
      if Checkouts.findOne({ assetId: tpl.data.docId, 'schedule.timeReserved': { $lte: date }, 'schedule.expectedReturn': { $gte: date }, 'approval.approved': { $ne: false }})
        return { enabled: false, classes: "datepicker-date-reserved", tooltip: "Reserved" }

Template.reserveModalUser.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'change input[name=timeReserved], change input[name=expectedReturn]': (e, tpl) ->
    if new Date(tpl.$('input[name=expectedReturn]').val()) - new Date(tpl.$('input[name=timeReserved]').val()) > 14*24*60*60*1000
      tpl.warning.set "Checkouts are typically limited to 2 weeks.  To improve the chances of approving your reservation, please note your use case and justification in the notes field."
    else
      tpl.warning.set null

  'click button[data-action=submit]': (e, tpl) ->
    # TODO: Permissions. Maybe move everything into methods.
    tpl.error.set(null)
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
      timeReserved = new Date(tpl.$('input[name=timeReserved]').val())
      expectedReturn = new Date(tpl.$('input[name=expectedReturn]').val())
      checkout = Checkouts.findOne {
        assetId: tpl.data.docId
        'approval.approved': { $ne: false }
        'schedule.timeReserved': { $lte: expectedReturn }
        'schedule.expectedReturn': { $gte: timeReserved }
      }
      if checkout
        tpl.error.set('This reservation would overlap with another. Please consider a different item or reservation window.')
      else
        tpl.success.set true
        Checkouts.insert
          assetId: tpl.data.docId
          assignedTo: Meteor.userId()
          schedule:
            timeReserved: new Date(tpl.$('input[name=timeReserved]').val())
            expectedReturn: new Date(tpl.$('input[name=expectedReturn]').val())

Template.reserveModalUser.onCreated ->
  @error = new ReactiveVar
  @warning = new ReactiveVar
  @success = new ReactiveVar false
