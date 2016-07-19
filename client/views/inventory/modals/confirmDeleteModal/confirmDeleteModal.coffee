Template.confirmDeleteModal.events
  'hidden.bs.modal': (e, tpl) ->
    $('body').css('padding-right: 0px;')
    Blaze.remove tpl.view

  'click button[data-action=delete]': (e, tpl) ->
    Meteor.call 'deleteItem', @_id, (err, res) ->
      unless err
        $('#confirmDeleteModal').modal('hide')
