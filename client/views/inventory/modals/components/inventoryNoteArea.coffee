Template.inventoryNoteArea.helpers
  noteParagraphs: -> @message.split('\n')

Template.inventoryNoteArea.events
  'click button': (e, tpl) ->
    Meteor.call 'addInventoryNote', @_id, tpl.$('textarea').val()
    tpl.$('textarea').val('')
