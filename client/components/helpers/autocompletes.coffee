UI.registerHelper 'userSettings', ->
  {
    position: "bottom"
    limit: 5
    rules: [
      collection: Meteor.users
      field: 'username'
      template: Template.userPill
      noMatchTemplate: Template.noMatchUserPill
      selector: (match) ->
        r = new RegExp match, 'i'
        return { $or: [ { username: r }, { displayName: r } ] }
    ]
  }

UI.registerHelper 'buildingSettings', ->
  {
    position: "bottom"
    limit: 5
    rules: [
      collection: Buildings
      field: 'building'
      template: Template.buildingPill
    ]
  }
