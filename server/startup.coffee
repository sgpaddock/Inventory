Meteor.startup ->
  Inventory._ensureIndex
    name: "text"
    propertyTag: "text"
    serialNo: "text"
    model: "text"
    owner: "text"
    location: "text"
    department: "text"
