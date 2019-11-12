Template.assetUser.helpers
  asset: ->
    return Inventory.findOne {propertyTag: Session.get('propertyTag')}

Template.assetUser.events
  'click button[data-toggle=modal]': (e, tpl) ->
    modal = tpl.$(e.currentTarget).data('modal')
    Blaze.renderWithData Template[modal], { docId: @documentId }, $('body').get(0)
    $("##{modal}").modal('show')