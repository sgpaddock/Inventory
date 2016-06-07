Template.upcoming.helpers
  checkouts: -> Checkouts.find {}, { sort: { 'schedule.timeReserved': 1 } }
  count: -> Checkouts.find().count()
  itemName: -> Inventory.findOne(@assetId)?.name
  checkedOut: -> Checkouts.findOne { _id: @_id, 'schedule.timeCheckedOut': { $exists: true }, 'schedule.timeReturned': { $exists: false } }
  todayHighlight: (date) ->
    if moment(date).dayOfYear() is moment().dayOfYear() #there's probably a better comparison but we only hvae an 8 day window
      'available'

 
Template.upcoming.onRendered ->
  Meteor.subscribe 'upcomingItems'

Template.upcoming.events
  'click button[data-action=checkOut]': (e, tpl) ->
    Blaze.renderWithData Template.confirmCheckoutModal, this, $('body').get(0)
    $('#confirmCheckoutModal').modal('show')

  'click button[data-action=checkIn]': (e, tpl) ->
    Blaze.renderWithData Template.checkInModal, { docId: @assetId }, $('body').get(0)
    $('#checkInModal').modal('show')

