excludedKeys = [ 'attachments', 'enteredByUserId', 'imageId', 'barcode', 'attachments.$', 'attachments.$.purpose', 'attachments.$.fileId']

Template.inventory.helpers
  collection: -> Inventory
  fields: -> _.difference _.keys(Inventory.simpleSchema()._schema), excludedKeys
  addFieldsToContext: ->
    console.log 'autotable.transformContext', @
    context = _.extend {}, @
    context.fieldTemplates = new ReactiveDict()
    
    if @collection? and window[@collection]
      console.log 'Found collection named ' + @collection + ' on window'
      
      # Get the keys, first by checking for presence of a simple-schema
      if window[@collection].simpleSchema?
        console.log 'Collection has a schema attached!'
        schema = window[@collection].simpleSchema()._schema
        fieldKeys = _.filter _.keys(schema), (k) -> k.indexOf('.$') == -1
        context.fields = _.map fieldKeys, (k) ->
          fieldName: k
        
        return context
        
  reactiveConfig: ->
    console.log 'reactiveConfig', @, arguments
    return @fieldTemplates
        
  assets: -> Inventory.find()

  fieldCellContext: (fn, doc) ->
    { fieldName: fn, value: doc[fn] }
    
  renderCell: ->
    tpl = @fieldConfig.get @fieldName
    if tpl?
      return Template[tpl]
    else
      return Template.atDefaultColumn

  modalId: ->
    console.log 'modalId', @, arguments
    'autotable-quick-add'

Template.inventory.events
  'click button[name=newAssetButton]': (e, tpl) ->
    Blaze.render Template.newAssetModal, $('body').get(0)
    $('#newAssetModal').modal('show')
