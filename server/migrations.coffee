Migrations.add
  version: 1
  up: ->
    Inventory.find().forEach (i) ->
      if i.location
        [ roomNumber, building ] = separateLocation(i.location)
        if roomNumber or building
          Inventory.update i._id, { $set: { building: building, roomNumber: roomNumber } }
          Buildings.upsert { building: building }, { $set: lastUse: new Date() }
 
Meteor.startup ->
  Migrations.migrateTo(1)
