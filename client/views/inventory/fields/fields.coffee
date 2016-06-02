Template.attachmentField.helpers
  file: ->
    FileRegistry.findOne(@fileId)

Template.attachmentField.events
  'click a[data-action=showAttachmentModal]': (e, tpl) ->
    e.stopPropagation()
    Iron.query.set 'attachmentId', @fileId

  'click a[data-action=uploadFile]': (e, tpl) ->
    e.stopPropagation()
    id = @documentId
    Media.pickLocalFile (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }
    tpl.$('.dropdown-toggle').dropdown('toggle')

  'click a[data-action=takePicture]': (e, tpl) ->
    id = @documentId
    Media.capturePhoto (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }



Template.inventoryActionsField.helpers
  isAdmin: -> Roles.userIsInRole Meteor.userId(), 'admin'

Template.inventoryActionsField.events
  'click button[data-toggle=modal]': (e, tpl) ->
    modal = tpl.$(e.currentTarget).data('modal')
    Blaze.renderWithData Template[modal], { docId: @documentId }, $('body').get(0)
    $("##{modal}").modal('show')
