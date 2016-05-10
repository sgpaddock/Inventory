@Inventory = new Mongo.Collection 'inventory'
@Inventory.attachSchema new SimpleSchema
  name:
    optional: true
    type: String
    denyUpdate: true
    label: "Asset Name"
  propertyTag:
    type: String
    optional: true
    denyUpdate: true
    unique: true
  deviceType:
    type: String
    allowedValues: [
      'PC'
      'Laptop'
      'IPad'
      'IMac'
      'Other Tablet'
      'Monitor'
      'Other Computer'
    ]
  serialNo:
    type: String
    optional: true
    label: "Serial Number"
    denyUpdate: true
  enteredByUserId:
    type: String
    denyUpdate: true
    optional: true # Will be taken care of by the server.
  enteredAtTimestamp:
    type: new Date()
    denyUpdate: true
    optional: true # Will be taken care of by the server.
  manufacturer:
    type: String
    denyUpdate: true
    allowedValues: [
      'Apple'
      'Dell'
      'Microsoft'
      'Other/Not Listed'
    ]
    optional: true
  modelNo:
    type: String
    optional: true
    label: "Model Number"
    denyUpdate: true
  department:
    type: String
    optional: true
    allowedValues: [
      'AAAS'
      'Air Force'
      'American Studies'
      'Anthropology'
      'Appalachian Center'
      'Army ROTC'
      'Aux Services'
      'Biology'
      'Chemistry'
      "Dean's Administration"
      'Earth and Environmental Sciences'
      'English'
      'Environmental and Sustainability Studies'
      'Center for English as a Second Language'
      'Geography'
      "Gender and Womens Studies"
      'History'
      'Hispanic Studies'
      'Hive'
      'IBU'
      'International Studies'
      'Linguistics'
      'Mathematics'
      'MCLLC'
      'Physics and Astronomy'
      'Philosophy'
      'Political Science'
      'Psychology'
      'Sociology'
      'Social Theory'
      'Statistics'
      'Writing, Rhetoric & Digital Studies'
      'Other/Not listed'
      'Unassigned'
    ]
  owner:
    type: String
    optional: true
  building:
    type: String
    optional: true
    allowedValues: [
      '1020 EXPORT STREET'
      '343 WALLER AVE'
      '424 EUCLID AVENUE'
      'APPALACHIAN CENTER'
      'ASTeCC'
      'AVIARY FACILITY'
      'BARKER HALL'
      'BBSRB'
      'BOWMAN HALL'
      'BRADLEY HALL'
      'BRECKINRIDGE HALL'
      'CENTER FOR APPLIED ENERGY'
      'CHEMISTRY-PHYSICS'
      'COMBS RESEARCH BUILDING'
      'ECOLOGICAL RESEARCH'
      'FUNKHOUSER'
      'JESSE HARRIS CENTER'
      'KASTLE HALL'
      'LAFFERTY HALL'
      'MACADAM OBSERVATORY'
      'MARKEY CANCER CENTER'
      'MATH HOUSE'
      'MDR3'
      'MDS'
      'MILLER HALL'
      'MINING/MINERALS BLDG'
      'PATTERSON OFFICE TOWER'
      'SCOTT ST BLDG'
      'SLONE RESEARCH BLDG'
      'SMALL ANIMAL LAB'
      'THOMAS HUNT MORGAN'
      'TOBACCO RESEARCH LAB'
      'UK LEXMARK CENTER'
      'WHITE HALL CLASSROOM'
    ]
  officeNo:
    type: String
    optional: true
    label: "Office Number"
  pictureId:
    type: String
    optional: true
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
  notes:
    type: String
    optional: true
  ticketNo:
    type: String
    optional: true
    label: "Waggle/Triage Ticket"
  imageId:
    type: String
    optional: true
  barcode:
    type: String
    optional: true
  category:
    optional: true
    type: String
  quantity:
    type: Number
    optional: true
  quantityUnit:
    type: String
    optional: true
    allowedValues: ['units', 'oz', 'spools']
  checkout:
    label: "Available for Checkout?"
    type: Boolean
    defaultValue: false

@Changelog = new Mongo.Collection 'changelog'
@Changelog.attachSchema new SimpleSchema
  itemId:
    type: String
    label: "Item ID"
  timestamp:
    type: new Date()
  userId:
    type: String
    optional: true
  username:
    type: String
    optional: true
  type:
    type: String
    allowedValues: [ 'field', 'attachment' ]
  oldValue:
    type: String
    optional: true
  newValue:
    type: String
    optional: true
  field:
    type: String
    optional: true
  otherId:
    type: String
    optional: true

@Deliveries = new Mongo.Collection 'deliveries'
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
    optional: true
    type: Object
  approval:
    optional: true
    type: Object
  notes:
    optional: true
    type: [Object]
  'notes.$.authorId':
    optional: true
    type: String
  'notes.$.timestamp':
    optional: true
    type: new Date()
  'notes.$.message':
    optional: true
    type: String
  'approval.approved':
    optional: true
    type: Boolean
  'approval.approverId':
    optional: true
    type: String
  'schedule.timeCheckedOut':
    optional: true
    type: new Date()
  'schedule.timeReturned':
    optional: true
    type: new Date()
  'schedule.timeReserved':
    optional: true
    type: new Date()
  'schedule.expectedReturn':
    optional: true
    type: new Date()
  'schedule.checkedOutBy':
    optional: true
    type: String
  'schedule.checkedInBy':
    optional: true
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
