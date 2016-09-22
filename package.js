if (typeof Meteor !== 'undefined') return;

Package.describe({
  name: 'inventory-tinytest',
  summary: 'tinytest package for Inventory app'
});

Package.onUse(function (api) {
  api.use([
    'mongo',
    'coffeescript',
    'aldeed:collection2',
    'hive:facets@0.0.1',
  ]);
  api.addFiles([
    'lib/facets.coffee'
  ]);
});

Package.onTest(function (api) {
  api.use([
    'coffeescript',
    'tinytest',
    'test-helpers',
  ]);

  api.addFiles([
    'tests/separateLocation-tests.coffee',
    'server/separateLocation.coffee'
  ], 'server');

});

