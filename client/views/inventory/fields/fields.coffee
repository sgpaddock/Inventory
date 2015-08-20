Template.ownerField.events
  'click button[data-action=showAssignItem]': (e, tpl) ->
    showEditField tpl
    tpl.$('input[name=assign-user]').focus()

  'click button[data-action=assignItem]': (e, tpl) ->
    # Interesting Blaze note: can't access Template.parentData from within the function, so have to pass it in.
    assignItem tpl, Template.parentData(3)._id

  'keyup input[name=assign-user]': (e, tpl) ->
    if e.which is 13
      assignItem tpl, Template.parentData(3)._id

  'keydown input[name=assign-user]': (e, tpl) ->
    # keyup means the input loses focus before we get the event, so keydown for escape.
    if e.keyCode is 27
      hideEditField tpl

  'focusout input[name=assign-user]': (e, tpl) ->
    if $(e.target).val() is ""
      hideEditField tpl

assignItem = (tpl, id) ->
  Meteor.call 'checkUsername', tpl.$('input[name=assign-user]').val(), (err, res) ->
    if res
      Inventory.update id, { $set: { owner: Meteor.users.findOne(res).username } }
      tpl.$('[data-toggle=tooltip]').tooltip('hide')
      tpl.$('input[name=assign-user]').val('')
      hideEditField tpl
    else
      tpl.$('[data-toggle=tooltip]').tooltip('show')

showEditField = (tpl) ->
  tpl.$('div.field-area').hide()
  tpl.$('div.field-edit-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')

hideEditField = (tpl) ->
  tpl.$('div.field-edit-area').hide()
  tpl.$('div.field-area').fadeIn(100)
  tpl.$('[data-toggle=tooltip]').tooltip('hide')


Template.attachmentField.helpers
  file: ->
    FileRegistry.findOne(@fileId)

Template.attachmentField.events
  'click a[data-action=uploadFile]': (e, tpl) ->
    id = Template.parentData(3)._id #I hate you Blaze
    Media.pickLocalFile (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }

  'click a[data-action=takePicture]': (e, tpl) ->
    id = Template.parentData(3)._id
    Media.capturePhoto (fileId) ->
      Inventory.update id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }


# Consider combining - maybe into meteor-autotable default 'edit fields' that pull selects from SS
Template.departmentField.helpers
  department: -> Inventory.simpleSchema()._schema.department.allowedValues

Template.departmentField.events
  'click button[data-action=editDepartment]': (e, tpl) ->
    showEditField tpl
    tpl.$('select[name=department]').val(Template.parentData(3).department)

  'click button[data-action=saveDepartment]': (e, tpl) ->
    Inventory.update Template.parentData(3)._id, { $set: { department: tpl.$('select[name=department]').val() } }
    hideEditField tpl

Template.buildingField.helpers
  building: -> Inventory.simpleSchema()._schema.building.allowedValues

Template.buildingField.events
  'click button[data-action=editBuilding]': (e, tpl) ->
    showEditField tpl
    tpl.$('select[name=building]').val(Template.parentData(3).building)

  'click button[data-action=saveBuilding]': (e, tpl) ->
    Inventory.update Template.parentData(3)._id, { $set: { building: tpl.$('select[name=building]').val() } }
    hideEditField tpl
 

Template.officeNoField.events
  'click button[data-action=editOfficeNo]': (e, tpl) ->
    showEditField tpl
    tpl.$('input[name=officeNo]').focus()
    tpl.$('input[name=officeNo]').val(Template.parentData(3).officeNo)

  'click button[data-action=saveOfficeNo]': (e, tpl) ->
    val = tpl.$('input[name=officeNo]').val()
    unless val is ""
      Inventory.update Template.parentData(3)._id, { $set: { officeNo: val } }
      hideEditField tpl
  'keyup input[name=officeNo]': (e, tpl) ->
    if e.which is 13
      val = tpl.$('input[name=officeNo]').val()
      unless val is ""
        Inventory.update Template.parentData(3)._id, { $set: { officeNo: val } }
        hideEditField tpl

  'keydown input[name=officeNo]': (e, tpl) ->
    if e.keyCode is 27
      hideEditField tpl
