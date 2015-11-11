Package.describe({
  name: "hive:autotable",
  summary: "Easily create tables from collections, with add and update abilities from autoform.",
  version: "0.1.0",
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.0');
  api.use(['coffeescript', 'mongo', 'check'], ['client', 'server']);
  api.use(['underscore', 'ui', 'templating', 'jquery', 'spacebars', 'reactive-dict', 'reactive-var'], 'client');
  api.use(['aldeed:simple-schema']);
  api.imply(['aldeed:simple-schema', 'aldeed:autoform', 'aldeed:collection2'], ['client', 'server']);

  api.addFiles(['client/autotable.html', 'client/autotable.coffee', 'client/autotable.css', 'client/modals.html', 'client/modals.coffee'], ['client']);
  api.addFiles(['lib/shared.coffee'], ['client', 'server']);
  api.addFiles(['server/publish.coffee'], ['server']);
  api.export('AutoTable', ['client', 'server']);

});

