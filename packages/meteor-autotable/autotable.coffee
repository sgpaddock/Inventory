Template.autotable.helpers
  addFieldsToContext: ->
    context = _.extend {}, @
    context.fieldTemplates = new ReactiveDict()
    if @collection? and window[@collection]
      if window[@collection].simpleSchema?
        ss = window[@collection].simpleSchema()
        if @fields
          keys = _.intersection(ss._schemaKeys, @fields)
        else if @omit
          keys = _.difference(ss._schemaKeys, @omit)
        else
          keys = ss._schemaKeys
        fieldKeys = _.filter keys, (k) -> k.indexOf('.$') == -1
        context.fields = _.map fieldKeys, (k) ->
          fieldName: k
          label: ss.label(k)
        
        return context
        
  reactiveConfig: ->
    console.log 'reactiveConfig', @, arguments
    return @fieldTemplates
        
  records: ->
    sort = {}
    sortKey = Session.get('sortKey') || 'name'
    sort[sortKey] = Session.get('sortOrder') || -1
    window[@collection].find({}, {sort: sort})
    
  fieldCount: (f) ->
    (f or @).fields.length

  isSortKey: ->
    @fieldName is Session.get('sortKey')

  isAscending: ->
    Session.get('sortOrder') is 1

  updateFormId: ->
    'update-' + @_id
  
  fieldCellContext: (fieldName, doc, grandparent) ->
    return { fieldName: fieldName, value: doc[fieldName], fieldConfig: grandparent.fieldTemplates }
    
  renderCell: ->
    tpl = @fieldConfig.get @fieldName
    if tpl?
      return Template[tpl]
    else
      return Template.atDefaultColumn

  modalId: ->
    'autotable-quick-add'
    
Template.autotable.events
  'click button.add': (e,tpl) ->
    $(tpl.find 'div[role="dialog"]').modal('show')
  'click tbody tr': (e,tpl) ->
    if tpl.data.updateRows
      $(e.target).closest('tr').next().toggle()
  'click span[class=field-table-heading]': (e, tpl) ->
    if Session.get('sortKey') is $(e.target).data('sort-key')
      Session.set 'sortOrder', (-1 * Session.get('sortOrder'))
    else
      Session.set 'sortOrder', 1
    Session.set 'sortKey', $(e.target).data('sort-key')

Template.atColumn.helpers
  customTemplateRenderContext: (fieldConfig) ->
    if @template
      fieldConfig.set @field, @template
    else if @edit
      fieldConfig.set @field, 'atEditColumn'
    else
      fieldConfig.set @field, 'atDefaultColumn'

Template.atEditColumn.helpers
  allowedValues: ->
    if @values
      @values
    else
      collection = Template.parentData(4).collection
      return window[collection].simpleSchema()._schema[@fieldName].allowedValues || null

Template.atEditColumn.events
  "click button[data-action=show-edit-field]": (e, tpl) ->
    item = Template.parentData(3) # GET RID OF PARENTDATA
    showEditField tpl
    tpl.$("[name=edit-field]").val(item[tpl.data.fieldName])

  'click button[data-action=save-field]': (e, tpl) ->
    collection = Template.parentData(4).collection # GET RID OF PARENTDATA
    set = {}
    set[tpl.data.fieldName] = tpl.$('[name=edit-field]').val()
    window[collection].update Template.parentData(3)._id, { $set: set } # GET RID OF PARENTDATA
    hideEditField tpl

  'keydown input[name=edit-field]': (e, tpl) ->
    if e.keyCode is 27
      hideEditField tpl

  'keyup input[name=edit-field]': (e, tpl) ->
    if e.which is 13
      val = tpl.$('[name=edit-field]').val()
      unless val is ""
        set = {}
        set[tpl.data.fieldName] = val
        collection = Template.parentData(4).collection # GET RID OF PARENTDATA
        window[collection].update Template.parentData(3)._id, { $set: set } # GET RID OF PARENTDATA
        hideEditField tpl


showEditField = (tpl) ->
  tpl.$('div.field-area').hide()
  tpl.$('div.field-edit-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')
  tpl.$('[name=edit-field]').focus()

hideEditField = (tpl) ->
  tpl.$('div.field-edit-area').hide()
  tpl.$('div.field-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')

