Migrations.add
  version: 1
  up: ->
    Inventory.find().forEach (i) ->
      if i.location
        [ roomNumber, building ] = separateLocation(i.location)
        if building then console.log building
        if roomNumber or building
          Inventory.update i._id, { $set: { building: building, roomNumber: roomNumber } }
 
Meteor.startup ->
  Migrations.migrateTo(1)
