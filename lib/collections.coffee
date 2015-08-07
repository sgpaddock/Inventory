@Assets = new Mongo.Collection('assets')
@Assets.attachSchema new SimpleSchema
  name:
    type: String
  description:
    type: String
    optional: true
  propertyTag:
    type: String
    optional: true
  deviceType:
    type: String
    optional: true
  serialNo:
    type: String
    optional: true
  enteredByUserId:
    type: String
  manufacturer:
    type: String
    optional: true
  modelNo:
    type: String
    optional: true
  department:
    type: String
  owner:
    type: String
  building:
    type: String
  officeNo:
    type: String
    label: "Office Number"
  attachments:
    type: [Object]
    optional: true
  'attachments.$.purpose':
    type: String
    allowedValues: [
      'ApprovedQuote'
      'PurchaseAcknowledgement'
      'PackingSlip'
      'DeliveryForm'
      'OffCampusEquipmentForm'
      'Other'
    ]
  'attachments.$.fileId':
    type: String
  imageId:
    type: String
    optional: true
  barcode:
    type: String
    optional: true
  category:
    type: String
  quantity:
    type: Number
    optional: true
  quantityUnit:
    type: String
    optional: true
    allowedValues: ['units', 'oz', 'spools']

@Deliveries = new Mongo.Collection('deliveries')
@Deliveries.attachSchema new SimpleSchema
  assetId:
    type: String
  deliveredByUserId:
    type: String
  deliveredTo:
    type: String
  deliveredToUserId:
    type: String
    optional: true
  recipientSignatureImageId:
    type: String
  timestamp:
    type:
      new Date()

@Scans = new Mongo.Collection 'scans'
@Scans.attachSchema new SimpleSchema
  latitude:
    type: Number
    decimal: true
  longitude:
    type: Number
    decimal: true
  imageId:
    type: String
    optional: true
  userId:
    type: String
  note:
    type: String
    optional: true
  timestamp:
    type: new Date()

@Checkouts = new Mongo.Collection 'checkouts'
@Checkouts.attachSchema new SimpleSchema
  assetId:
    type: String
  assignedTo:
    type: String
  schedule:
    type: Object
  'schedule.timeCheckedOut':
    type: new Date()
  'schedule.timeReturned':
    type: new Date()
  'schedule.timeReserved':
    type: new Date()
  'schedule.expectedReturn':
    type: new Date()
  'schedule.checkedOutBy':
    type: String
  'schedule.checkedInBy':
    type: String
  

Meteor.users.attachSchema new SimpleSchema
  username:
    type: String
    label: "Username"
  defaultQueue:
    type: String
    optional: true
    label: "Default Queue"
  displayName:
    type: String
    optional: true
    label: "Display Name"
  employeeNumber:
    type: String
    optional: true
    label: "Employee Number"
  mail:
    type: String
    label: "Email Address"
  emails:
    type: [String]
    optional: true
    label: "Additional Email Addresses"
  memberOf:
    type: [String]
    label: "Member Of"
  department:
    type: String
    optional: true
  physicalDeliveryOfficeName:
    type: String
    label: "Physical Delivery Office"
    optional: true
  services:
    type: Object
    optional: true
    blackbox: true
  status:
    type: Object
    optional: true
    blackbox: true
  title:
    optional: true
    type: String
    label: "Title"
