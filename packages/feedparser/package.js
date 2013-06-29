Npm.depends({feedparser: '0.16.1'});

Package.on_use(function(api, where) {
  api.add_files(['feedparser.js'], 'server');
})

