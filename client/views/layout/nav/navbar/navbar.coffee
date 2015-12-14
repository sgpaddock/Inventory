Template.navbar.events
  'click a[id=logout]': ->
    Meteor.logout()

  'click .yamm .dropdown-menu': (e, tpl) ->
    e.stopPropagation()

