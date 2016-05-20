tickDeps = new Tracker.Dependency()

Meteor.setInterval ->
  tickDeps.changed()
, 1000

fromNowReactive = (date) ->
  tickDeps.depend()
  return moment(date).fromNow()

Template.timeFromNow.helpers
  parsedTime: -> fromNowReactive(@date)
  fullTime: -> moment(@date).format('MMMM Do YYYY, h:mm:ss a')
