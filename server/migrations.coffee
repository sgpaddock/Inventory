Migrations.add
  version: 1
  up: ->
    Inventory.find().forEach (i) ->
      if i.location
        [ roomNumber, building ] = separateLocation(i.location)
        if roomNumber or building
          Inventory.update i._id, { $set: { building: building, roomNumber: roomNumber } }
          Buildings.upsert { building: building }, { $set: lastUse: new Date() }

Migrations.add
  version: 2
  up: ->
    Inventory.find().forEach (i) ->
      Job.push new WarrantyLookupJob
        inventoryId: i._id
 
Meteor.startup ->
  Migrations.migrateTo(2)
