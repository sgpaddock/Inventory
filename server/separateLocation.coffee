@separateLocation = (loc) ->
  roomNumber = loc.match(/[0-9]+\w/)?[0]
  building = loc.match(/\b\D+/)?[0].trim()
  return [ roomNumber, building ]
