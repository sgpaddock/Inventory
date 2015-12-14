fields = ['name', 'description', 'propertyTag', 'serialNo', 'deviceType', 'manufacturer', 'modelNo', 'department', 'building', 'officeNo', 'owner']
Template.assetModal.helpers
  item: -> Inventory.findOne(@docId)
  changelog: -> Changelog.find { itemId: @_id }

Template.assetModal.events
  'click button[data-action=submit]': (e, tpl) ->
    obj = {}
    _.each fields, (f) ->
      unless tpl.$("[data-schema-key=#{f}]").is(':disabled')
        obj[f] = tpl.$("[data-schema-key=#{f}]").val()
    obj['checkout'] = tpl.$('[data-schema-key=checkout]').is(':checked')
    Inventory.update tpl.data.docId, { $set: obj }
    $('#assetModal').modal('hide')

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

Template.assetModal.created = ->
  Meteor.subscribe 'item', @data.docId
