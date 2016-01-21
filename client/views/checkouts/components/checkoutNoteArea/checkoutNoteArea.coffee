Template.checkoutNoteArea.events
  'keyup input[name=newNote]': (e, tpl) ->
    if e.keyCode is 13 and tpl.$('input[name=newNote]').val()
      note = {
        message: tpl.$('input[name=newNote]').val()
        authorId: Meteor.userId()
        timestamp: new Date()
      }
      Checkouts.update @_id, { $push: { notes: note } }, (err, res) ->
        if res
          tpl.$('input[name=newNote]').val('')

  'click button[data-action=addNote]': (e, tpl) ->
    if tpl.$('input[name=newNote]').val()
      note = {
        message: tpl.$('input[name=newNote]').val()
        authorId: Meteor.userId()
        timestamp: new Date()
      }
      Checkouts.update @_id, { $push: { notes: note } }, (err, res) ->
        if res
          tpl.$('input[name=newNote]').val('')
