Template.cloneModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view

Template.deleteModal.events
  'click button[data-action=delete]': (e, tpl) ->
    tpl.data.collection.remove tpl.data.doc._id
    tpl.$('updateModal').modal('hide')
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
  
Template.updateModal.events
  'hidden.bs.modal': (e, tpl) ->
    Blaze.remove tpl.view
