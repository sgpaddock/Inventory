Template.userDashboard.helpers
  notificationSettings: -> Meteor.user()?.notificationSettings || {}
  saved: -> Template.instance().saved.get()
  user: -> Meteor.user()
  isAdmin: -> Roles.userIsInRole Meteor.userId(), 'admin'

Template.userDashboard.events
  'click button[data-action=submit]': (e, tpl) ->
    notificationSettings = {}

    _.each tpl.$('input[type=checkbox]'), (i) ->
      notificationSettings[i.name] = tpl.$(i).is(':checked')

    Meteor.users.update Meteor.userId(), {$set:{ notificationSettings: notificationSettings }}, (e, res) ->
      if res then tpl.saved.set true

Template.userDashboard.onRendered ->
  tpl = @
  tpl.find('#saved-message')._uihooks =
    insertElement: (node, next) ->
      $(node).hide().insertBefore(next).fadeIn(100).delay(3000).fadeOut 500, () ->
        @remove()
        tpl.saved.set false

Template.userDashboard.onCreated ->
  @saved = new ReactiveVar(false)

Template.settingsCheckbox.helpers
  checked: ->
    if @setting then "checked"
