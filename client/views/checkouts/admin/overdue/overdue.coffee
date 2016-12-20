Template.overdue.onCreated ->
  @subscribe 'overdueItems'

Template.overdue.helpers
  count: ->
    today = moment().hours(0).minutes(0).seconds(0).toDate()
    Checkouts.find({
      'schedule.expectedReturn': { $lt: today }
      'schedule.timeReturned': { $exists: false }
      'schedule.timeCheckedOut': { $exists: true }
    }).count()
  overdueCheckouts: ->
    today = moment().hours(0).minutes(0).seconds(0).toDate()
    Checkouts.find({
      'schedule.expectedReturn': { $lt: today }
      'schedule.timeReturned': { $exists: false }
      'schedule.timeCheckedOut': { $exists: true }
    })
  itemName: -> Inventory.findOne(@assetId)?.name
  checkedOut: -> Checkouts.findOne { _id: @_id, 'schedule.timeCheckedOut': { $exists: true }, 'schedule.timeReturned': { $exists: false } }
  todayHighlight: (date) ->
    if moment(date).dayOfYear() is moment().dayOfYear() #there's probably a better comparison but we only hvae an 8 day window
      'available'

Template.overdue.events
  'click button[data-action=checkIn]': (e, tpl) ->
    Blaze.renderWithData Template.checkInModal, { docId: @assetId }, $('body').get(0)
    $('#checkInModal').modal('show')

