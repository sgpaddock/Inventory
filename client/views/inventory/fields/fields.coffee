Template.attachmentField.helpers
  file: ->
    FileRegistry.findOne(@fileId)

Template.attachmentField.events
  'click a[data-action=showAttachmentModal]': (e, tpl) ->
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
