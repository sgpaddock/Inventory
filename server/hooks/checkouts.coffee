scheduleMail = (mail) ->
  if mail.date <= new Date()
    Email.send
      from: Meteor.settings.email.fromEmail
      to: mail.email
      subject: mail.subject
      html: mail.html
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

  scheduleMail
    email: user.mail
    subject: "REMINDER: Your checkout of item #{item.name} for #{moment(doc.schedule.timeReserved).format('LL')}"
    html: "This email is to remind you of your request for checkout item #{item.name} for dates
      #{moment(doc.schedule.timeReserved).format('LL')} through #{moment(doc.schedule.expectedReturn).format('LL')}.
      Please visit POT 915, 923, or 951 to pick up your item when ready."
    date: moment(doc.schedule.timeReserved).subtract(1, 'days').hours(17).minutes(0).seconds(0).toDate() # 1 day before time served, 5pm

  scheduleMail
    email: user.mail
    subject: "Your checkout of item #{item.name} is due soon"
    html: "Your expected return date for item #{item.name} is #{moment(doc.schedule.expectedReturn).format('LL')}. Please have the item ready to return. It may be dropped off in POT 915, 923, or 951."
    date: moment(doc.schedule.expectedReturn).subtract(3, 'days').hours(17).minutes(0).seconds(0).toDate() # 3 days before expected return, 5pm

  scheduleMail
    email: user.mail
    subject: "Your checkout of item #{item.name} is due today"
    html: "Your expected return date for item #{item.name} is today. The item may be dropped off in POT 915, 923, or 951."
    date: moment(doc.schedule.expectedReturn).hours(8).minutes(0).seconds(0).toDate() # Day of expected return, 8am

Checkouts.after.insert (userId, doc) ->
  if doc.approval?.approved
    scheduleCheckoutReminders userId, doc

Checkouts.after.update (userId, doc, fieldNames, modifier, options) ->
  # Check if this is an update approving/rejecting a request. If so, send the appropriate email.
 
  if modifier.$set?.approval?.approved or modifier.$set?['approval.approved']
    item = Inventory.findOne(doc.assetId)
    scheduleMail
      email: Meteor.users.findOne(doc.assignedTo)?.mail
      subject: "Your reservation of #{item.name} has been approved"
      html: "Your reservation of #{item.name} for #{moment(doc.schedule.timeReserved).format('LL')} has been approved.
      Please visit POT 915, 923, or 951 to pick up your item on that date when ready."
      date: new Date()
    scheduleCheckoutReminders userId, doc

  else if modifier.$set?.approval?.approved is false or modifier.$set?['approval.approved'] is false
    item = Inventory.findOne(doc.assetId)
    scheduleMail
      email: Meteor.users.findOne(doc.assignedTo)?.mail
      subject: "Your reservation of #{item.name} has been rejected"
      html: "Your reservation of #{item.name} for #{moment(doc.schedule.timeReserved).format('LL')} has been rejected.<br>
      Reason given: #{doc.approval.reason}"
      date: new Date()

    
