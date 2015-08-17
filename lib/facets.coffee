if Meteor.isServer
  Facets.configure Inventory,
    department: String
    owner: String
    building: String
