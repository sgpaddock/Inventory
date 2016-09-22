# Drop old text index if it exists and ensure new one
Inventory._dropIndex("name_text_propertyTag_text_serialNo_text_model_text_owner_text_location_text_department_text")
Meteor.startup ->
  Inventory._ensureIndex
    name: "text"
    propertyTag: "text"
    serialNo: "text"
    model: "text"
    owner: "text"
    roomNumber: "text"
    building: "text"
    department: "text"
