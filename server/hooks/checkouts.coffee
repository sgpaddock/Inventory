@scheduleMail = (mail) ->
  unless mail.checkoutId and Checkouts.findOne(mail.checkoutId)?.schedule?.timeReturned
    if mail.date <= new Date()
      return
    else
      id = Random.id()
      SyncedCron.add
        name: id
        schedule: (parser) ->
          parser.recur().on(mail.date).fullDate()
        job: ->
          Email.send
            from: Meteor.settings.email.fromEmail
            to: mail.email
            subject: mail.subject
            html: mail.html
          SyncedCron.remove id


scheduleCheckoutReminders = (userId, doc) ->
  # Schedule reminder emails.
  item = Inventory.findOne(doc.assetId)
  user = Meteor.users.findOne(doc.assignedTo)
  name = item.name || item.model # Name is preferred, but not required, so model as fallback

  scheduleMail
    checkoutId: doc._id
    email: user.mail
    subject: "REMINDER: Your checkout of item #{name} for #{moment(doc.schedule.timeReserved).format('LL')}"
    html: "This email is to remind you of your request for checkout item #{name} for dates
      #{moment(doc.schedule.timeReserved).format('LL')} through #{moment(doc.schedule.expectedReturn).format('LL')}.
      Please visit POT 915, 923, or 961 to pick up your item when ready."
    date: moment(doc.schedule.timeReserved).subtract(1, 'days').hours(17).minutes(0).seconds(0).toDate() # 1 day before time served, 5pm

  unless moment(doc.schedule.expectedReturn).subtract(3, 'days').isBefore(doc.schedule.timeReserved)
    scheduleMail
      checkoutId: doc._id
      email: user.mail
      subject: "Your checkout of item #{name} is due soon"
      html: "Your expected return date for item #{name} is #{moment(doc.schedule.expectedReturn).format('LL')}. Please have the item ready to return. It may be dropped off in POT 915, 923, or 961."
      date: moment(doc.schedule.expectedReturn).subtract(3, 'days').hours(17).minutes(0).seconds(0).toDate() # 3 days before expected return, 5pm

  scheduleMail
    checkoutId: doc._id
    email: user.mail
    subject: "Your checkout of item #{name} is due today"
    html: "Your expected return date for item #{name} is today. The item may be dropped off in POT 915, 923, or 961."
    date: moment(doc.schedule.expectedReturn).hours(8).minutes(0).seconds(0).toDate() # Day of expected return, 8am

Checkouts.after.insert (userId, doc) ->
  if doc.approval?.approved
    scheduleCheckoutReminders userId, doc
  else
    users = Roles.getUsersInRole('admin').fetch()
    emails = _.pluck _.filter(users, (u) -> u.notificationSettings?.notifyOnNewCheckout), 'mail'
    item = Inventory.findOne(doc.assetId)
    requester = Meteor.users.findOne(doc.assignedTo)
    name = item.name || item.model # Name is preferred, but not required, so model as fallback
    scheduleMail
      email: emails
      subject: "New checkout request for item #{name}"
      html: "Requester #{requester.username} requested item #{name} for checkout from
      #{moment(doc.schedule.timeReserved).format('LL')} to #{moment(doc.schedule.expectedReturn).format('LL')}.
      Review checkout requests at <a href='#{Meteor.absoluteUrl()}checkouts'>#{Meteor.absoluteUrl()}checkouts</a>."
      date: new Date()

Checkouts.after.update (userId, doc, fieldNames, modifier, options) ->
  # Check if this is an update approving/rejecting a request. If so, send the appropriate email.
  if modifier.$set?.approval?.approved or modifier.$set?['approval.approved']
    item = Inventory.findOne(doc.assetId)
    name = item.name || item.model
    reason = if doc.approval.reason?.trim().length then "<br>Reason given: #{doc.approval.reason}" else ""
    scheduleMail
      email: Meteor.users.findOne(doc.assignedTo)?.mail
      subject: "Your reservation of #{name} has been approved"
      html: "Your reservation of #{name} for #{moment(doc.schedule.timeReserved).format('LL')} has been approved.
      Please visit POT 915, 923, or 961 to pick up your item on that date when ready.#{reason}"
      date: new Date()
    scheduleCheckoutReminders userId, doc

  else if modifier.$set?.approval?.approved is false or modifier.$set?['approval.approved'] is false
    item = Inventory.findOne(doc.assetId)
    name = item.name || item.model
    scheduleMail
      email: Meteor.users.findOne(doc.assignedTo)?.mail
      subject: "Your reservation of #{name} has been rejected"
      html: "Your reservation of #{name} for #{moment(doc.schedule.timeReserved).format('LL')} has been rejected.<br>
      Reason given: #{doc.approval.reason}"
      date: new Date()

    
