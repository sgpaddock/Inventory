Template.assetHistoryModal.helpers
  item: -> Inventory.findOne(@docId)
  changelog: -> Changelog.find { itemId: @_id }
  deliveries: -> Deliveries.find { assetId: @_id }
  typeIs: (type) -> @type is type

Template.assetHistoryModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

Template.assetHistoryModal.created = ->
  @subscribe 'item', @data.docId
