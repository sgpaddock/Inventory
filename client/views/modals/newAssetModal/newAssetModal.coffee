fields = ['name', 'description', 'propertyTag', 'serialNo', 'deviceType', 'manufacturer', 'modelNo', 'department', 'building', 'officeNo', 'owner']

Template.newAssetModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

  'click button[type=submit]': (e, tpl) ->
    obj = {}
    _.each fields, (f) ->
      obj[f] = tpl.$("[data-schema-key=#{f}]").val()

    Inventory.insert obj
    $('#newAssetModal').modal('hide')

  'click button[data-action=checkUsername]': (e, tpl) ->
    val = tpl.$('input[data-schema-key=owner]').val()
    unless val.length < 1
      Meteor.call 'checkUsername', val, (err, res) ->
        if res
          tpl.$('input[data-schema-key=owner]').parent().parent().removeClass('has-error').addClass('has-success')
          tpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-ok"></span>')
          tpl.$('button[data-action=checkUsername]').removeClass('btn-danger').removeClass('btn-primary').addClass('btn-success')
        else
          tpl.$('input[data-schema-key=owner]').parent().parent().removeClass('has-success').addClass('has-error')
          tpl.$('button[data-action=checkUsername]').removeClass('btn-success').removeClass('btn-primary').addClass('btn-danger')
          tpl.$('button[data-action=checkUsername]').html('<span class="glyphicon glyphicon-remove"></span>')


