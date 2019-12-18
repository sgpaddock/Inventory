Template.assetUser.helpers
  asset: ->
    return Inventory.findOne {propertyTag: Session.get('propertyTag')}
  file: -> FileRegistry.findOne(@fileId)

Template.assetUser.events
  'click button[data-toggle=modal]': (e, tpl) ->
    modal = tpl.$(e.currentTarget).data('modal')
    Blaze.renderWithData Template[modal], { docId: @documentId }, $('body').get(0)
    $("##{modal}").modal('show')

  'click a[data-action=showAttachmentModal]': (e, tpl) ->
    Iron.query.set 'attachmentId', @fileId  