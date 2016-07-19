fields = ['name', 'description', 'propertyTag', 'serialNo', 'deviceType', 'manufacturer', 'modelNo', 'department', 'building', 'officeNo', 'owner']
Template.editAssetModal.helpers
  item: -> Inventory.findOne(@docId)
  changelog: -> Changelog.find { itemId: @_id }
  typeIs: (type) -> @type is type
  filename: -> FileRegistry.findOne(@otherId).filename

Template.editAssetModal.events
  'click button[data-action=submit]': (e, tpl) ->
    win = ->
      obj = {}
      _.each fields, (f) ->
        unless tpl.$("[data-schema-key=#{f}]").is(':disabled')
          obj[f] = tpl.$("[data-schema-key=#{f}]").val()
      obj['checkout'] = tpl.$('[data-schema-key=checkout]').is(':checked')
      Inventory.update tpl.data.docId, { $set: obj }
      $('#editAssetModal').modal('hide')
    checkUsername tpl, win

  'click button[data-action=delete]': (e, tpl) ->
    Blaze.renderWithData Template.confirmDeleteModal, this, $('body').get(0)
    $('#editAssetModal').modal('hide')
    $('#confirmDeleteModal').modal('show')

  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[data-action=checkUsername]': (e, tpl) ->
    checkUsername tpl

Template.editAssetModal.created = ->
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
