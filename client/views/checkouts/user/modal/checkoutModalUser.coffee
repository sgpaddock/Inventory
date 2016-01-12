Template.checkoutModalUser.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName
  error: -> Template.instance().error.get()
  checkoutShouldBeDisplayed: ->
    @approval.approved is true or @assignedTo is Meteor.userId()

Template.checkoutModalUser.rendered = ->
  this.$('.datepicker').datepicker({
    orientation: "top" # up is down
  })

Template.checkoutModalUser.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[data-action=submit]': (e, tpl) ->
    # TODO: Permissions. Maybe move everything into methods.
    Template.instance().error.set(null)
    if tpl.$('input[name=onBehalfOf]').val()
      userId = Meteor.call 'checkUsername', tpl.$('input[name=onBehalfOf]').val()
    timeReserved = new Date(tpl.$('input[name=timeReserved]').val())
    expectedReturn = new Date(tpl.$('input[name=expectedReturn]').val())
    checkout = Checkouts.findOne {
      assetId: tpl.data.docId
      'schedule.timeReserved': { $lte: expectedReturn }
      'schedule.expectedReturn': { $gte: timeReserved }
    }
    console.log checkout
    if checkout
      Template.instance().error.set('This reservation would overlap with another. Please consider a different item or reservation window.')
    else
      Checkouts.insert
        assetId: tpl.data.docId
        assignedTo: userId || Meteor.userId()
        schedule:
          timeReserved: new Date(tpl.$('input[name=timeReserved]').val())
          expectedReturn: new Date(tpl.$('input[name=expectedReturn]').val())

Template.checkoutModalUser.onCreated ->
  this.error = new ReactiveVar()
