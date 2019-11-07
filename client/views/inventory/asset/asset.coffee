Template.asset.helpers
  asset: ->
    return Inventory.findOne {propertyTag: Session.get('propertyTag')}