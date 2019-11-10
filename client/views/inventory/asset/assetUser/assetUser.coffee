Template.assetUser.helpers
  asset: ->
    return Inventory.findOne {propertyTag: Session.get('propertyTag')}