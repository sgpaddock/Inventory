if Meteor.isServer
  Tinytest.add "location separation for migration", (test) ->
    test.equal separateLocation("925 Patterson Office Tower"), [ "925", "Patterson Office Tower" ]
    test.equal separateLocation("POT 925"), [ "925", "POT" ]
    test.equal separateLocation("Patterson Office Tower"), [ undefined, "Patterson Office Tower" ]
    test.equal separateLocation("361B JSB"), [ "361B", "JSB" ]
