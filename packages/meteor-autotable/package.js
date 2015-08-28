Package.describe({
  name: "noahadler:autotable",
  summary: "A counterpart to autoform, for working with whole collections in table form.",
  version: "0.1.0",
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.0');
  api.use('coffeescript', ['client', 'server']);
  api.use(['underscore', 'ui', 'templating', 'jquery', 'spacebars', 'reactive-dict'], 'client');

  api.imply(['aldeed:simple-schema', 'aldeed:autoform', 'aldeed:collection2'], ['client', 'server']);

  api.addFiles(['autotable.html', 'autotable.coffee'], ['client']);

});

