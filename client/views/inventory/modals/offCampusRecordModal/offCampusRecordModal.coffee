Template.offCampusRecordModal.helpers
  item: -> Inventory.findOne(@docId)
  success: -> Template.instance().success.get()
  error: -> Template.instance().error.get()
  warning: -> Template.instance().warning.get()

Template.offCampusRecordModal.events
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
      item = @
      username = tpl.$('input[name=ldap]').val()
      Meteor.call 'recordItemDelivery',
        username,
        tpl.$('input[name=password]').val(),
        item._id
        (err, res) ->
          if err
            tpl.error.set('Invalid credentials. Please try again.')
          else if username isnt item.owner
            tpl.warning.set "User checking out is not the user this item was originally assigned to.
             The delivery has been recorded for user #{username}."
          else
            tpl.success.set(true)

Template.offCampusRecordModal.onCreated ->
  @error = new ReactiveVar()
  @success = new ReactiveVar(false)
  @warning = new ReactiveVar()
