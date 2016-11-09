Template.bulkRecordPickupModal.helpers
  items: -> _.map Session.get('selected'), (i) -> Inventory.findOne(i)
  success: -> Template.instance().success.get()
  error: -> Template.instance().error.get()

Template.bulkRecordPickupModal.events
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

  'click button[data-action=login], keyup input': (e, tpl) ->
    if e.keyCode is 13 or !e.keyCode
      username = tpl.$('input[name=ldap]').val()
      Meteor.call 'recordItemDelivery',
        username,
        tpl.$('input[name=password]').val(),
        Session.get('selected')
        (err, res) ->
          if err
            tpl.error.set('Invalid credentials. Please try again.')
          else
            tpl.success.set(true)

Template.bulkRecordPickupModal.onCreated ->
  @error = new ReactiveVar()
  @success = new ReactiveVar(false)
