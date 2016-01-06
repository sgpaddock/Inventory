Template.checkoutModal.helpers
  item: -> Inventory.findOne { _id: @docId }
  checkout: -> Checkouts.find { assetId: @_id }
  admin: -> true
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName

Template.checkoutModal.rendered = ->
  this.$('.datepicker').datepicker({
    orientation: "top" # up is down
  })

Template.checkoutModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[data-action=submit]': (e, tpl) ->
    # TODO: Validate/figure out how this is actually going to work
    if tpl.$('input[name=onBehalfOf]').val()
      id = Meteor.call 'checkUsername', tpl.$('input[name=onBehalfOf]').val()
    Checkouts.insert
      assetId: tpl.data.docId
      assignedTo: id || Meteor.userId()
      schedule:
        timeReserved: new Date(tpl.$('input[name=timeReserved]').val())
        expectedReturn: new Date(tpl.$('input[name=expectedReturn]').val())
    $('#checkoutModal').modal('hide')
