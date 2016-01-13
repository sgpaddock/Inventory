Template.checkoutModalAdmin.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  admin: -> true
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()

Template.checkoutModalAdmin.rendered = ->
  this.$('.datepicker').datepicker({
    orientation: "top" # up is down
  })

Template.checkoutModalAdmin.events
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
      if tpl.$('input[name=onBehalfOf]').val()
        Meteor.call 'checkUsername', tpl.$('input[name=onBehalfOf]').val(), (err, res) ->
          if res
            insertCheckout e, tpl, res
          else
            tpl.error.set("User not found.")
      else
        insertCheckout e, tpl, Meteor.userId()


  'click button[data-action=approve]': (e, tpl) ->
    Checkouts.update @_id, { $set: { 'approval.approved': true, 'approval.approverId': Meteor.userId() } }
  'click button[data-action=reject]': (e, tpl) ->
    Checkouts.update @_id, { $set: { 'approval.approved': false, 'approval.approverId': Meteor.userId() } }

Template.checkoutModalAdmin.onCreated ->
  this.error = new ReactiveVar()

insertCheckout = (e, tpl, userId) ->
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
    Checkouts.insert {
      assetId: tpl.data.docId
      assignedTo: userId
      schedule:
        timeReserved: timeReserved
        expectedReturn: expectedReturn
      approval:
        approved: true
        approverId: Meteor.userId()
    }, (err, res) ->
      if res
        tpl.$('input[name=timeReserved]').val("")
        tpl.$('input[name=expectedReturn]').val("")
        tpl.$('input[name=onBehalfOf]').val("")
