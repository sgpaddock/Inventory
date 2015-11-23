Template.ownerField.events
  'click button[data-action=showAssignItem]': (e, tpl) ->
    showEditField tpl
    tpl.$('input[name=assign-user]').focus()

  'click button[data-action=assignItem]': (e, tpl) ->
    # Interesting Blaze note: can't access Template.parentData from within the function, so have to pass it in.
    assignItem tpl, @_id

  'keyup input[name=assign-user]': (e, tpl) ->
    if e.which is 13
      assignItem tpl, tpl.data.documentId

  'keydown input[name=assign-user]': (e, tpl) ->
    # keyup means the input loses focus before we get the event, so keydown for escape.
    if e.keyCode is 27
      hideEditField tpl

  'focusout input[name=assign-user]': (e, tpl) ->
    if $(e.target).val() is ""
      hideEditField tpl

assignItem = (tpl, id) ->
  Meteor.call 'checkUsername', tpl.$('input[name=assign-user]').val(), (err, res) ->
    if res
      Inventory.update id, { $set: { owner: Meteor.users.findOne(res).username } }
      tpl.$('[data-toggle=tooltip]').tooltip('hide')
      tpl.$('input[name=assign-user]').val('')
      hideEditField tpl
    else
      tpl.$('[data-toggle=tooltip]').tooltip('show')

showEditField = (tpl) ->
  $('div.field-edit-area').hide()
  $('div.field-area').fadeIn(100)
  tpl.$('div.field-area').hide()
  tpl.$('div.field-edit-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')

hideEditField = (tpl) ->
  tpl.$('div.field-edit-area').hide()
  tpl.$('div.field-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')

Template.attachmentField.helpers
  file: ->
    FileRegistry.findOne(@fileId)

Template.attachmentField.events
  'click a[data-action=showAttachmentModal]': (e, tpl) ->
    Iron.query.set 'attachmentId', @fileId

  'click a[data-action=uploadFile]': (e, tpl) ->
    id = @documentId
    Media.pickLocalFile (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }

  'click a[data-action=takePicture]': (e, tpl) ->
    id = @documentId
    Media.capturePhoto (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }
