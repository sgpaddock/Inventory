Template.ownerField.events
  'click button[data-action=showAssignItem]': (e, tpl) ->
    tpl.$('div.assigned-user').hide()
    tpl.$('div.assign-user-field').fadeIn(100)
    tpl.$('input[name=assign-user]').focus()

  'click button[data-action=assignItem]': (e, tpl) ->
    # Interesting Blaze note: can't access Template.parentData from within the function, so have to pass it in.
    assignItem tpl, Template.parentData(3)._id

  'keyup input[name=assign-user]': (e, tpl) ->
    if e.which is 13
      assignItem tpl, Template.parentData(3)._id

  'keydown input[name=assign-user]': (e, tpl) ->
    # keyup means the input loses focus before we get the event, so keydown for escape.
    if e.keyCode is 27
      hideFields tpl

  'focusout input[name=assign-user]': (e, tpl) ->
    if $(e.target).val() is ""
      hideFields tpl

assignItem = (tpl, id) ->
  Meteor.call 'checkUsername', tpl.$('input[name=assign-user]').val(), (err, res) ->
    if res
      Inventory.update id, { $set: { owner: Meteor.users.findOne(res).username } }
      tpl.$('[data-toggle=tooltip]').tooltip('hide')
      tpl.$('input[name=assign-user]').val('')
      hideFields tpl
    else
      tpl.$('[data-toggle=tooltip]').tooltip('show')

hideFields = (tpl) ->
  tpl.$('div.assign-user-field').hide()
  tpl.$('div.assigned-user').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')


Template.attachmentField.helpers
  file: ->
    FileRegistry.findOne(@fileId)

Template.attachmentField.events
  'click a[data-action=uploadFile]': (e, tpl) ->
    id = Template.parentData(3)._id #I hate you Blaze
    Media.pickLocalFile (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }

  'click a[data-action=takePicture]': (e, tpl) ->
    id = Template.parentData(3)._id
    Media.capturePhoto (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }

