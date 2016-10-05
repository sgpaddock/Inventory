Template.confirmCheckoutModal.helpers
  name: -> Inventory.findOne(@assetId).name
  error: -> Template.instance().error.get()
  success: -> Template.instance().success.get()
  warning: -> Template.instance().warning.get()
  assignedToUsername: -> Meteor.users.findOne(@assignedTo).username

Template.confirmCheckoutModal.events
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
    if tpl.$('input[name=agreed]').is(':checked')
      tpl.error.set null
      Meteor.call 'checkPassword',
        tpl.$('input[name=ldap]').val(),
        tpl.$('input[name=password]').val(),
        (err, res) ->
          if res

            if tpl.$('input[name=ldap]').val() isnt Meteor.users.findOne(tpl.data.assignedTo)?.username
              tpl.warning.set "User checking out is not the user this item was originally assigned to.
               User #{tpl.$('input[name=ldap]').val()} will now be responsible for this item."
            else
              tpl.success.set(true)

            Checkouts.update tpl.data._id, { $set:
              'schedule.assignedTo': res
              'schedule.timeCheckedOut': new Date()
              'schedule.checkedOutBy': Meteor.userId()
            }
          else
            tpl.error.set('Invalid credentials. Please try again.')
    else
      tpl.error.set "Please read and agree to the Hive Checkout Terms."


  'keyup input': (e, tpl) ->
    if e.keyCode is 13
      tpl.$('button[data-action=login]').click()

Template.confirmCheckoutModal.onCreated ->
  @error = new ReactiveVar()
  @success = new ReactiveVar(false)
  @warning = new ReactiveVar()
