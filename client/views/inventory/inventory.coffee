getFilters = ->
  filters = {
    department: Iron.query.get 'department'
    owner: Iron.query.get 'owner'
    building: Iron.query.get 'building'
  }

  for k,v of filters
    if _.isUndefined(v)
      delete filters[k]

  return filters

Template.inventory.helpers
  tableSettings: ->
    fields =  [
      'propertyTag',
      { key: 'serialNo', class: 'hidden-xs' }
      'model',
      { key: 'department', class: 'hidden-xs' }
      { key: 'owner', tpl: Template.ownerField },
      'location',
      { key: 'attachments', tpl: Template.attachmentField, sortable: false, class: 'hidden-xs' }
    ]
    if Roles.userIsInRole Meteor.userId(), 'admin'
      fields.push { key: 'actions', label: "Actions", tpl: Template.inventoryActionsField, sortable: false }
    return {
      fields: fields
      subscription: "inventory"
      class: "autotable table table-condensed"
      filters: getFilters
    }

Template.inventory.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')

Template.inventory.rendered = ->
  @autorun ->
    # Render attachment modal on query parameter change.
    attachmentParam = Iron.query.get('attachmentId')
    if attachmentParam and not $('#attachmentModal').length
      Meteor.subscribe 'file', attachmentParam
      file = FileRegistry.findOne(attachmentParam)
      if file
        Blaze.renderWithData Template.attachmentModal, { attachmentId: attachmentParam }, $('body').get(0)
        $('#attachmentModal').modal('show')
      else
        $('#attachmentModal').modal('hide')
