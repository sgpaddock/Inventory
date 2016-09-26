fields = [ 'name', 'propertyTag', 'serialNo', 'model', 'department', 'roomNumber', 'building', 'owner' ]
Template.editAssetModal.helpers
  item: -> Inventory.findOne(@docId)
  file: -> FileRegistry.findOne(@fileId)
  departments: -> _.map departments, (v) -> { label: v, value: v }

Template.editAssetModal.events
  'click button[data-action=attachFile]': (e, tpl) ->
     Media.pickLocalFile (fileId) =>
       Inventory.update @_id, { $addToSet: { attachments: { fileId: fileId , purpose: 'Other' } } }

  'click a[data-action=showAttachmentModal]': (e, tpl) ->
    Iron.query.set 'attachmentId', @fileId

  'click button[data-action=submit]': (e, tpl) ->
    obj = {}
    _.each fields, (f) ->
      unless tpl.$("[data-schema-key=#{f}]").is(':disabled')
        obj[f] = tpl.$("[data-schema-key=#{f}]").val()
    obj['checkout'] = tpl.$('[data-schema-key=checkout]').is(':checked')
    obj['enteredIntoEbars'] = tpl.$('[data-schema-key=enteredIntoEbars]').is(':checked')
    Inventory.update tpl.data.docId, { $set: obj }
    $('#editAssetModal').modal('hide')

  'click button[data-action=delete]': (e, tpl) ->
    Blaze.renderWithData Template.confirmDeleteModal, this, $('body').get(0)
    $('#editAssetModal').modal('hide')
    $('#confirmDeleteModal').modal('show')

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[data-action=checkUsername]': (e, tpl) ->
    checkUsername tpl

Template.editAssetModal.created = ->
  @subscribe 'buildings'
  @subscribe 'item', @data.docId

checkUsername = (tpl, winCb, failCb) ->
  # A check username function for this template only.
  val = tpl.$('input[data-schema-key=owner]').val()
  unless val.length < 1
    Meteor.call 'checkUsername', val, (err, res) ->
      if res
        tpl.$('input[data-schema-key=owner]').parent().parent().removeClass('has-error').addClass('has-success')
        tpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-ok"></span>')
        tpl.$('button[data-action=checkUsername]').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        if winCb then winCb()
      else
        tpl.$('input[data-schema-key=owner]').parent().parent().removeClass('has-success').addClass('has-error')
        tpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
        tpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')
        if failCb then failCb()

departments = [
  'AAAS'
  'Advising'
  'Air Force'
  'American Studies'
  'Anthropology'
  'Appalachian Center'
  'Army ROTC'
  'Aux Services'
  'Biology'
  'Chemistry'
  "Dean's Administration"
  'Earth and Environmental Sciences'
  'English'
  'Environmental and Sustainability Studies'
  'Center for English as a Second Language'
  'Geography'
  "Gender and Womens Studies"
  'History'
  'Hispanic Studies'
  'Hive'
  'IBU'
  'International Studies'
  'Linguistics'
  'Mathematics'
  'MCLLC'
  'OPSVAW'
  'Physics and Astronomy'
  'Philosophy'
  'Political Science'
  'Psychology'
  'Sociology'
  'Social Theory'
  'Statistics'
  'Writing, Rhetoric & Digital Studies'
  'Other/Not listed'
  'Unassigned'
]
