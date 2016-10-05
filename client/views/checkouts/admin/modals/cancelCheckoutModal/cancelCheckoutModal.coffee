Template.cancelCheckoutModal.helpers
  item: -> Inventory.findOne(@assetId)
  error: -> Template.instance().error.get()
  checkout: -> Checkouts.findOne(@checkoutId)
  displayName: -> Meteor.users.findOne(@assignedTo)?.displayName


Template.cancelCheckoutModal.events
  'show.bs.modal': (e, tpl) ->
    zIndex = 1040 + ( 10 * $('.modal:visible').length)
    $(e.target).css('z-index', zIndex)
    setTimeout ->
      $('.modal-backdrop').not('.modal-stack').css('z-index',  zIndex-1).addClass('modal-stack')
    , 10

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
    if $('.modal:visible').length
      $(document.body).addClass('modal-open')

  'click button[data-action=cancel]': (e, tpl) ->
    if tpl.$('input[name=cancel]').val() is 'Cancel'
      Meteor.call 'cancelCheckout', @_id, (err, res) ->
        if err
          tpl.error.set err
        else
          tpl.$('#cancelCheckoutModal').modal('hide')

    else
      tpl.error.set "Please type 'Cancel' in the field to confirm."

Template.cancelCheckoutModal.onCreated ->
  @error = new ReactiveVar
