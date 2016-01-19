Template.checkoutCheckoutModal.helpers
  name: -> Inventory.findOne(@assetId).name
  error: -> Template.instance().error.get()
  success: -> Template.instance().success.get()

Template.checkoutCheckoutModal.events
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

  'click button[data-action=login]': (e, tpl) ->
    Meteor.call 'checkPassword',
      tpl.$('input[name=ldap]').val(),
      tpl.$('input[name=password]').val(),
      (err, res) ->
        if res
          tpl.success.set(true)
          Checkouts.update tpl.data._id, { $set:
            'schedule.timeCheckedOut': new Date()
            'schedule.checkedOutBy': Meteor.userId()
          }
        else
          tpl.error.set('Invalid credentials. Please try again.')

  'keyup input': (e, tpl) ->
    if e.keyCode is 13
      tpl.$('button[data-action=login]').click()

Template.checkoutCheckoutModal.onCreated ->
  @error = new ReactiveVar()
  @success = new ReactiveVar(false)
