Meteor.startup ->
  Inventory._ensureIndex {
    name: "text"
    propertyTag: "text"
    serialNo: "text"
    model: "text"
    owner: "text"
    roomNumber: "text"
    building: "text"
    department: "text"
  }, { name: "invTextIndex" }
