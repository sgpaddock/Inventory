findOverdueItems = ->
  console.log "Finding overdue items"
  startOfToday = moment().hours(0).minutes(0).seconds(0).toDate()
  checkouts = Checkouts.find({
    'schedule.expectedReturn': { $lt: startOfToday }
    'schedule.timeReturned': { $exists: false }
    'schedule.timeCheckedOut': { $exists: true }
  }).fetch()
  console.log "Overdue checkouts: #{JSON.stringify(checkouts)}"

  _.each checkouts, (c) ->
    console.log 'overdue'
    user = Meteor.users.findOne(c.assignedTo)
    item = Inventory.findOne(c.assetId)
    if item
      Email.send
        from: Meteor.settings.email.fromEmail
        to: user?.mail
        subject: "Your checkout of item #{item.name} is overdue"
        html: "Your checkout of item #{item.name} was expected to be returned on #{moment(c.schedule.expectedReturn).format('LL')}.
        By our records, it still has not been checked in. Please return the item to POT 915, 923, or 961.
        If you believe this message is in error, please submit a help request."

SyncedCron.add
  name: 'Remind about overdue checkouts'
  schedule: (parser) -> parser.text 'at 8:00 am on Monday through Friday'
  job: ->
    findOverdueItems()

SyncedCron.start()

